## 前置き

[NebLua](https://github.com/Tsukina-7mochi/neblua) という Lua 製 Lua バンドラを作ったので書き散らかします。なお、以下の情報は Lua5.4 時点での情報です。

### 参考文献

- [https://www.lua.org/manual/5.4/](Lua 6.4 Reference Manual)

## Lua のモジュール解決方法を知りたい

[https://www.lua.org/manual/5.4/manual.html#6.3](公式リファレンス) に全て書いてあります。以下にモジュール解決の手順を要約します。

### モジュール解決の方法

Lua ではモジュールを `require(modname)` 関数を用いて行います。`requre` の動作は次のようになっています:

1. `package.loaded[modname]` (すでにロードされたモジュールが格納されている) に値があれば、それを返す
2. `package.searchers` テーブルに含まれる関数 (loader 関数) によって順に解決を試みる (以下デフォルトで設定されている `package.searchers` の場合)
    1. `package.preload[modname]` テーブルを見て、値 (関数でなければならない) を持つなら loader として扱う
    2. `package.path` をもとに Lua loader を探す
        - Lua の相対パスはすべて CWD からの相対パスになります
    3. `package.cpath` をもとに C loader を探す
    4. all-in-one-loader (C のサブモジュールの解決をしてくれるらしい？) を呼ぶ
3. loader が見つかれば、loader にモジュール名と loader data (searcher から返される) を与えて呼び出す
    - loader data は例えばファイルから読み込まれた loader ならファイルパスが渡される
4. `package.loaded[modname]` に loader の戻り値 (何も返されないなど nil の場合は `true`) を格納する
5. `package.loaded[modname]` に格納した値と loader data を返す

### 疑似実装

```lua
package.searchers = {
    function(modname)
        return package.preload[modname]
    end,
    function(modname)
        searchLuaLoader(package.path, modname)
    end,
    function(modname)
        searchCLoader(package.cpath, modname)
    end,
    function(modname)
        allInOneLoader(modname)
    end
}

function require(modname)
    local loaded = package.loaded[modname]
    if loaded ~= nil and loaded ~= false then
        return loaded
    end

    for _, searcher in ipairs(package.searchers) do
        local loader, loaderData = searcher(modname)
        if loader ~= nil then
            local loaded = loader(modname, loaderData)
            package.loaded[modname] = loaded or true
            return package.loaded[modname], loaderData
        end
    end

    error("Cannot find loader for module " .. modname)
end
```

## モジュール解決をカスタムしたい

上の記述から、モジュール解決をカスタムする方法は次の 3 つが挙げられます

1. `package.loaded[modname]` にロード結果を格納する
2. `package.preload[modname]` にチャンクを格納する
3. `package.searchers` に loader 関数を設定する

今回は主に 3 の方法を利用することになりました。

## バンドル後のファイルの概要

上のモジュール解決の仕組みを利用してファイルをまとめていきます。

### バンドルするファイル

`/main.lua` が `/module1.lua` に依存しているだけの簡単な構成です。

- `/main.lua`
  ```lua
  print("main")
  require("module1")
  ```
- `/module1.lua`
  ```lua
  print("module1")
  ```

### バンドル後

一部を省略していますが、バンドル後にのファイルをこのようにします。

```lua
package.bundleLoader = {}

package.bundleLoader["./module1.lua"] = {
    line = debug.getinfo(1).currentline,
    loader = function(...)
        print("module1")
    end
}

package.bundleLoader["./main.lua"] = {
    line = debug.getinfo(1).currentline,
    loader = function(...)
        print("main")
        require("module1")
    end
}

--- `package.bundleLoader` のモジュールを探す searcher
local function bundlerSearcher(moduleName)
    moduleName = moduleName:gsub("%.", pathSeparator)

    local templates = split(package.path, templateSeparator)
    for _, template in ipairs(templates) do
        local path = template:gsub(substitutionPoint, moduleName)
        local resolvedPath = resolvePath(path)
        local loader = package.bundleLoader[resolvedPath]
        if loader ~= nil and loader.loader ~= nil then
            return loader.loader, path
        end
    end

    return nil
end

-- bundlerSearcher を一番最初に挿入
table.insert(package.searchers, 1, bundlerSearcher)

-- エントリーポイントの呼び出し
local result = table.pack(pcall(require, "main", ...))
local success = result[1]
if not success then
    io.stderr:write(result[2])
    error("Error occurred in bundled file.")
end

return table.unpack(result, 2)
```

### バンドル後のファイルのポイント

- `package.bundleLoader` に元のファイルの内容が全て格納されている
  - `line` は `debug.getinfo(1).currentline` により現在の行 (C でいう `__LINE__`) を取得、これは後述のエラーの書き換えのため
  - `loader` はファイルの内容を `function` でラップしたもの
- `bundlerSearcher` で `pacakge.bundleLoader` の内容を探索
  - モジュール名を `package.path` を使って探索するファイル名に変換
  - 該当するファイル名のエントリが `package.bundleLoader` に入っていればその `loader` の値が返される
  - この関数を `package.searchers` に代入
- 最後にエントリーポイントを `require` を使って呼び出しています

これにより、

1. モジュールが `require` によって呼び出される
2. `bundlerSearcher` が `package.bundleLoad[ファイル名].loader` を返す
3. (Lua が) loader を実行してその結果を `package.loaded` に格納、結果を返す

という操作によりモジュールを読み込むことができるようになりました。

## エラーの出力を書き換える

一般的にバンドルしたファイルでエラーが発生すると、エラーは `foo.bundle.lua:1234: in function ...` のようにバンドル後のファイル名で表示されます。デバッグが非常にしづらくなってしまうため、ファイル名と行数を書き換えたくなります。そこで `xpcall` 関数が登場します。

### xpcall 関数を使ってエラーを書き換える

`xpcall` 関数は `pcall` 関数の機能に加え、エラーハンドラを持つことができます:。このエラーハンドラでエラーの内容を書き換えることが可能です。

ここで次のようなエラーハンドラを用意します。

```lua
local loaderLineOffset = -1
---Error handler for xpcall
---@param err any
---@return any
local errorHandler = function(err)
    local srcName = debug.getinfo(1).short_src:gsub("[^%w]", "%%%0")
    local pattern = srcName .. ":(%d+):"

    local message = debug.traceback(err, 2):gsub(pattern, function(line)
        local lineNumber = tonumber(line)

        local loaderLine = -1
        local loaderName = nil
        for name, loader in pairs(package.bundleLoader) do
            if loader.line ~= nil and loaderLine < loader.line and loader.line < lineNumber then
                loaderLine = loader.line
                loaderName = name
            end
        end

        return loaderName .. ":" .. (lineNumber - loaderLine + loaderLineOffset) .. ":"
    end)

    return message
end
```

このハンドラでは、

1. `[ファイル名]:[行数]:` のパターンを見つける
2. 行数より後ろにあるモジュールのうち、最も上にあるものを見つける
    - このモジュールの中でエラーが発生しています
3. `package.bundleLoader` で設定している行数との差分にオフセットを加えてモジュール内でのエラーが発生した行数を求める
4. `[モジュールのファイル名]:[モジュール内での行数]:` の形に置き換える

という操作を行っています。このエラーハンドラを利用して

```lua
local result = table.pack(xpcall(require, errorHandler, "entryPoint"))
```

のようにしてエラーを書き換えることができます。

## loadfile, dofile を書き換える

`loadfile` 関数と `dofile` 関数が呼ばれた際に `package.bundleLoader` の中身を見るように書き換ることでバンドルした結果を参照してくれます。

```lua
-- Replace dofile
local originalDoFile = dofile
_ENV.dofile = function(path)
    local loader = package.bundleLoader[path]
    if loader ~= nil and loader.loader ~= nil then
        return loader.loader()
    else
        return originalDoFile(path)
    end
end

-- Replace loadfile
local originalLoadFile = loadfile
_ENV.loadfile = function(path, ...)
    local loader = package.bundleLoader[path]
    if loader ~= nil and loader.loader ~= nil then
        return loader.loader
    else
        return originalLoadFile(path, ...)
    end
end
```

## テキストファイルをバンドルする

`requireText` 関数でテキストを読み込めるようにします。 `require` 関数を書き換えてアセットタイプを読み込むようにしても良かったのですが、非バンドル環境では行儀が悪いためやめました。`requireText` 関数は次のように定義しました。

```lua
local function requireText(path)
    if package.loaded[path] ~= nil then
        return package.loaded[path]
    end

    package.loaded[path] = getFileContent(path)

    return package.loaded[path]
end
```

`package.loaded` にそのファイルが読み込まれていればその値を返し、読まれていなければファイルの内容を読み込んで `package.loaded` に設定します (`getFileContent` 関数はファイルを開いて中身の文字列を読んで返す関数です)。非バンドル環境では初回の呼び出しではファイルの文字列が読まれ、2 回目以降ではキャッシュされた値が返されます。

バンドラでは予め `package.loaded` に値を設定しておくことで文字列をバンドルすることができます。つまり

```lua
package.loaded["./some-file"] = "file content is here"
```

のようにすることで予め読み込まれている状態になり、`requireText` した際にはこの値を返すことになります。

## あとがき?

構文解析すら使ってないシンプル構成ですが、依存ファイルをエントリーポイントから調べたりする機能もない絶賛α版なのでちょっとづつ機能を追加していきたいですね
