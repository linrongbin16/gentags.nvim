# Changelog

## [3.0.2](https://github.com/linrongbin16/gentags.nvim/compare/v3.0.1...v3.0.2) (2024-04-18)


### Bug Fixes

* **config:** make ctags and workspace opt overwriteable ([#44](https://github.com/linrongbin16/gentags.nvim/issues/44)) ([f731331](https://github.com/linrongbin16/gentags.nvim/commit/f731331af6daf53eed303151509ad8c7bcce449c))
* **config:** makes path more unified ([#45](https://github.com/linrongbin16/gentags.nvim/issues/45)) ([9e8a893](https://github.com/linrongbin16/gentags.nvim/commit/9e8a893e2e13e18d0b9669637042c7475c74f12c))
* **dispatcher:** dispatch terminate properly ([#40](https://github.com/linrongbin16/gentags.nvim/issues/40)) ([b6f0c06](https://github.com/linrongbin16/gentags.nvim/commit/b6f0c061df0a95eae1c725f32d7cee92c8b3ebae))

## [3.0.1](https://github.com/linrongbin16/gentags.nvim/compare/v3.0.0...v3.0.1) (2024-03-06)


### Bug Fixes

* **configs:** fix disabled filenames/workspaces filter ([#35](https://github.com/linrongbin16/gentags.nvim/issues/35)) ([bff9e44](https://github.com/linrongbin16/gentags.nvim/commit/bff9e44bf4db39c5707e8e9d9aee3ea038b7f362))

## [3.0.0](https://github.com/linrongbin16/gentags.nvim/compare/v2.0.0...v3.0.0) (2024-03-06)


### ⚠ BREAKING CHANGES

* **configs:** use list configs instead of hash map! ([#34](https://github.com/linrongbin16/gentags.nvim/issues/34))

### Performance Improvements

* **disabled:** allow disable specific filenames/filetypes/workspaces ([#32](https://github.com/linrongbin16/gentags.nvim/issues/32)) ([e9b0096](https://github.com/linrongbin16/gentags.nvim/commit/e9b0096fb6c1c64965cf1385b441b5e6ee1a5b96))


### Code Refactoring

* **configs:** use list configs instead of hash map! ([#34](https://github.com/linrongbin16/gentags.nvim/issues/34)) ([d3e2bc1](https://github.com/linrongbin16/gentags.nvim/commit/d3e2bc1ff433b19d7c7d1b61c091cef9ed5a2ee8))

## [2.0.0](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.5...v2.0.0) (2024-01-11)


### ⚠ BREAKING CHANGES

* **config:** use map instead of list for ctags opts ([#28](https://github.com/linrongbin16/gentags.nvim/issues/28))

### Bug Fixes

* **config:** fix workspace detect ([#30](https://github.com/linrongbin16/gentags.nvim/issues/30)) ([abf982a](https://github.com/linrongbin16/gentags.nvim/commit/abf982a715688c75d4561e90fcc0608427d35fc2))


### Performance Improvements

* **config:** use map instead of list for ctags opts ([#28](https://github.com/linrongbin16/gentags.nvim/issues/28)) ([526aff9](https://github.com/linrongbin16/gentags.nvim/commit/526aff92d3ac5108573a6eca0674208bae44336b))

## [1.1.5](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.4...v1.1.5) (2024-01-10)


### Bug Fixes

* **crash:** fix terminate crash ([#26](https://github.com/linrongbin16/gentags.nvim/issues/26)) ([c6a0b21](https://github.com/linrongbin16/gentags.nvim/commit/c6a0b2120965565f6b34bd270af778274e50ac58))


### Performance Improvements

* **configs:** exclude non-source code filetypes ([b893fcc](https://github.com/linrongbin16/gentags.nvim/commit/b893fcc8fdf4c92df3abfed9ebe3f439fc09c994))

## [1.1.4](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.3...v1.1.4) (2023-12-30)


### Performance Improvements

* **initialize:** only initialize tags once for each workspace ([#20](https://github.com/linrongbin16/gentags.nvim/issues/20)) ([29856d4](https://github.com/linrongbin16/gentags.nvim/commit/29856d411469af890fb9c3d97be3953972239edd))

## [1.1.3](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.2...v1.1.3) (2023-12-29)


### Bug Fixes

* **cwd:** fix current working directory for single file ([#16](https://github.com/linrongbin16/gentags.nvim/issues/16)) ([fe58416](https://github.com/linrongbin16/gentags.nvim/commit/fe58416a90dbeb9457b0fdd94e4059446c000d5a))


### Performance Improvements

* **test:** improve test cases ([#16](https://github.com/linrongbin16/gentags.nvim/issues/16)) ([fe58416](https://github.com/linrongbin16/gentags.nvim/commit/fe58416a90dbeb9457b0fdd94e4059446c000d5a))

## [1.1.2](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.1...v1.1.2) (2023-12-28)


### Performance Improvements

* **update:** incremental update tags on single file save ([#11](https://github.com/linrongbin16/gentags.nvim/issues/11)) ([194a08c](https://github.com/linrongbin16/gentags.nvim/commit/194a08cf637069b035c75ec79a60d9cfa6535a84))

## [1.1.1](https://github.com/linrongbin16/gentags.nvim/compare/v1.1.0...v1.1.1) (2023-12-28)


### Bug Fixes

* **singlefile:** fix single file mode ctags parameters ([#9](https://github.com/linrongbin16/gentags.nvim/issues/9)) ([d4d77a9](https://github.com/linrongbin16/gentags.nvim/commit/d4d77a93b3387e87c03b709a35e8513ccb4dcba1))

## [1.1.0](https://github.com/linrongbin16/gentags.nvim/compare/v1.0.0...v1.1.0) (2023-12-28)


### Features

* **mvp:** MVP ([#3](https://github.com/linrongbin16/gentags.nvim/issues/3)) ([510976f](https://github.com/linrongbin16/gentags.nvim/commit/510976fd2c7220f424887e1cc8da0064852c44dd))

## 1.0.0 (2023-12-11)


### Features

* **mvp:** init CI ([#1](https://github.com/linrongbin16/gentags.nvim/issues/1)) ([6e9a98a](https://github.com/linrongbin16/gentags.nvim/commit/6e9a98ad5af6d8fcb63c37b2df7671f61b568b62))
