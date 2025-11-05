# Changelog

## [0.6.0](https://github.com/Tsukina-7mochi/neblua/compare/v0.5.3...v0.6.0) (2025-11-05)


### Features

* add and remove methods to path library ([72ceafa](https://github.com/Tsukina-7mochi/neblua/commit/72ceafa0cb3f363bc71fb834592fc7dbb403f567))
* add external option ([c693536](https://github.com/Tsukina-7mochi/neblua/commit/c6935360180373fd572c4f169deb3b7a0bf935ea))
* change includes to opt-in ([c0f3a58](https://github.com/Tsukina-7mochi/neblua/commit/c0f3a58adb62c7036c64da09a0ef4f85580e055b))
* revert require text to take path-form sepcifier ([40deb83](https://github.com/Tsukina-7mochi/neblua/commit/40deb83f263542fee92ac315024aa360ac86bd52))
* revert require text to take path-form sepcifier ([93a288f](https://github.com/Tsukina-7mochi/neblua/commit/93a288fd2c13de76c4c20b701ec8ee04a21c9606))
* rewrite bundler ([2166312](https://github.com/Tsukina-7mochi/neblua/commit/216631250d1378d94a385d0e8f371e27c17f0874))

## [0.5.3](https://github.com/Tsukina-7mochi/neblua/compare/v0.5.2...v0.5.3) (2025-02-18)


### Bug Fixes

* call loader of entry module directory instead of calling require ([#33](https://github.com/Tsukina-7mochi/neblua/issues/33)) ([a5aa391](https://github.com/Tsukina-7mochi/neblua/commit/a5aa391e69a4a134ab73c3c4400de6a3723073ec))

## [0.5.2](https://github.com/Tsukina-7mochi/neblua/compare/v0.5.1...v0.5.2) (2025-02-17)


### Bug Fixes

* fix path separators in package.path are not converted into internal path separator ([1c704f4](https://github.com/Tsukina-7mochi/neblua/commit/1c704f4b500b728b0fec9a7f00f9fd699a95d55b))

## [0.5.1](https://github.com/Tsukina-7mochi/neblua/compare/v0.5.0...v0.5.1) (2025-02-17)


### Bug Fixes

* use `/` as path separator internally regardless of the value in `package.config` ([72c4fb3](https://github.com/Tsukina-7mochi/neblua/commit/72c4fb342bb86de143c401e86aac99d92d2d6f7b))

## [0.5.0](https://github.com/Tsukina-7mochi/neblua/compare/v0.4.0...v0.5.0) (2025-02-17)


### Features

* add function to use `print` as fallback for `io.stderr:write` ([f87dfa7](https://github.com/Tsukina-7mochi/neblua/commit/f87dfa78fa074d84b8a13d06c86c7fb319158736))

## [0.4.0](https://github.com/Tsukina-7mochi/neblua/compare/v0.3.0...v0.4.0) (2024-10-01)


### Features

* update header of generated file ([b8ac904](https://github.com/Tsukina-7mochi/neblua/commit/b8ac904d49ed2152c53dabb0d1b8ccc7128061ff))
* update husky and commitlint ([27e0525](https://github.com/Tsukina-7mochi/neblua/commit/27e0525e207e14effac1e9b267fd127355eaa1e9))


### Bug Fixes

* fix make script ([f0433cc](https://github.com/Tsukina-7mochi/neblua/commit/f0433ccceb2394e4acfe850144bc10b5fd444c60))

## [0.2.0](https://github.com/Tsukina-7mochi/neblua/compare/v0.1.3...v0.2.0) (2023-11-24)


### Features

* add root-dir options to cli ([33016b3](https://github.com/Tsukina-7mochi/neblua/commit/33016b339243b22c2024b5b3085ac99b4192bea9))


### Bug Fixes

* add global argument to entry point call ([1ebfa30](https://github.com/Tsukina-7mochi/neblua/commit/1ebfa303fdbbdbb70c81ba260c785a15cfe87c21))

## [0.1.3](https://github.com/Tsukina-7mochi/neblua/compare/v0.1.2...v0.1.3) (2023-11-24)


### Bug Fixes

* fix some string.gsub calls to method style calls ([307484d](https://github.com/Tsukina-7mochi/neblua/commit/307484d847b3d16750382e2d06dfa9f2f63daac4))
