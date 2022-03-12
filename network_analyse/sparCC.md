# sparCC.md
sparCC is used for network analysis of microbiota, recommand by Chen.

Cytoscape?

[sparCC reference](https://blog.csdn.net/woodcorpse/article/details/106554536)

[network analysis](https://mp.weixin.qq.com/s?__biz=MzIxNzc1Mzk3NQ%3D%3D&chksm=97f5b52fa0823c394ad8374eb3c2707e525eb4cd49dce028dcb131a7342171b592d2f8f19fb3&idx=1&lang=zh_CN&mid=2247484727&scene=21&sn=1014fd472ff6b0bb2ea9af9093c198d6&token=668390449#wechat_redirect)

using plotly for interactive graphics

```R
library(plotly)
library(igraph)
library(igraphdata)

data(karate, package="igraphdata")
G <- upgrade_graph(karate)
L <- layout.circle(G)

```

