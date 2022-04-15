# sparCC.md
sparCC is used for network analysis of microbiota, recommand by Chen.

Cytoscape?

[sparCC reference](https://blog.csdn.net/woodcorpse/article/details/106554536)

In Gmrepo only part of the network (the first 100 co-occurring pairs) is shown here due to too many co-occurring pairs are there.

[network analysis](https://mp.weixin.qq.com/s?__biz=MzIxNzc1Mzk3NQ%3D%3D&chksm=97f5b52fa0823c394ad8374eb3c2707e525eb4cd49dce028dcb131a7342171b592d2f8f19fb3&idx=1&lang=zh_CN&mid=2247484727&scene=21&sn=1014fd472ff6b0bb2ea9af9093c198d6&token=668390449#wechat_redirect)




## 使用waston上的R-phyloseq对数据进行抽平处理，去掉一些低丰度的otu
```R
library(phyloseq)

otu <- read.table("08_table_level6.tsv", header = T, sep = "\t", row.names = 1)
otu1 <- otu_table(otu, taxa_are_rows = T)
otu2 = phyloseq(otu1)
set.seed(123)
otu_Flattening1 = rarefy_even_depth(otu2,replace = TRUE)

sample_sums(otu2)
sample_sums(otu_Flattening1)

otu_Flattening1 = as.data.frame(otu_Flattening1@.Data )
write.table (otu_Flattening1, file ="otu_Flattening1.csv",sep =",", quote =FALSE)

#注意输出的文件需要在最前面加一个逗号，否则列对不上
```
这里产生的otu_Flattening1.csv文件第一列是taxa name，在下一步使用sparCC处理后将被替换成数字而失去taxa name， 推测这个顺序是没有被改变的，所以在最后用cytoscape画图的时候直接把otu_Flattening1.csv文件第一列复制过去作为第一列。

## 对于抽平后的数据，使用sparcc

```bash
# /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC
# 进入抽平后的丰度表所在的目录
# python /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC/MakeBootstraps.py -h

## 第一步计算相关性矩阵
python /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC/Compute_SparCC.py  -n Experiment_SparCC \
-di otu_Flattening1.csv -ni 5 --save_cor=./basis_corr/cor_sparcc.csv

## 第二步，获得自举分布
python /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC/MakeBootstraps.py otu_Flattening1.csv \
-t permutation_#.csv \
-p ./pvals/

## 第三步，计算伪p值
### 在获得了自举分布（多次重抽样的随机数据集）后，计算这些随机数据集中OTU的相关程度，即获得随机值的相关矩阵。
for i in `seq 0 99`; 
    do 
    python /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC/Compute_SparCC.py --name Experiment_PVals \
    -di ./pvals/permutation_$i.csv --save_cor ./pvals/perm_cor_$i.csv >> case_example.log; 
done

### 通过观测值的相关矩阵中系数（cor0），以及随机值的相关矩阵中系数（corN），考虑 |cor0|>|corN| 的频率，获得伪 p 值（我猜的应该是这样......）
python /mnt/raid7/mingyuwang/gut_fungus/tools/SparCC/PseudoPvals.py ./basis_corr/cor_sparcc.csv ./pvals/perm_cor_#.csv 100 \
-o ./pvals_two_sided.csv -t two_sided

```

## 合并相关矩阵和p值矩阵，获得最终网络
不妨考虑使用R进行矩阵操作，根据相关性的强度以及显著水平自定义筛选，只保留具有显著的强相关关系，如下示例，最终获得邻接矩阵类型的网络文件。
```R
setwd("PATH/06_cooccurrence/")
#观测值的相关矩阵
cor_sparcc <- read.delim('./basis_corr/cor_sparcc.csv', row.names = 1, sep = ',', check.names = FALSE)
 
#伪 p 值矩阵
pvals <- read.delim('./pvals_two_sided.csv', row.names = 1, sep = ',', check.names = FALSE)
 
#保留 |相关性|≥0.8 且 p<0.01的值
# cor_sparcc[abs(cor_sparcc) < 0.8] <- 0 试验用的数据集中相关性都不高，阈值设为0.3也没有显著相关性，这份数据包括两种表型的人群，相关性不高的原因？
 
pvals[pvals>=0.01] <- -1
pvals[pvals<0.01 & pvals>=0] <- 1
pvals[pvals==-1] <- 0
 
#筛选后的邻接矩阵
adj <- as.matrix(cor_sparcc) * as.matrix(pvals)
diag(adj) <- 0    #将相关矩阵中对角线中的值（代表了自相关）转为 0
write.table(data.frame(adj, check.names = FALSE), 'network_adj.txt', col.names = NA, sep = '\t', quote = FALSE)

```


```R
# 使用R作图
library(plotly)
library(igraphdata)

##网络格式转换
library(igraph)
 
#输入数据，邻接矩阵
network_adj <- read.delim('network_adj.txt', row.names = 1, sep = '\t', check.names = FALSE)
head(neetwork_adj)[1:6]    #邻接矩阵类型的网络文件
 
#邻接矩阵 -> igraph 的邻接列表，获得含权的无向网络
g <- graph_from_adjacency_matrix(as.matrix(neetwork_adj), mode = 'undirected', weighted = TRUE, diag = FALSE)
g    #igraph 的邻接列表
 
#这种转换模式下，默认的边权重代表了 sparcc 计算的相关性（存在负值）
#由于边权重通常为正值，因此最好取个绝对值，相关性重新复制一列作为记录
E(g)$sparcc <- E(g)$weight
E(g)$weight <- abs(E(g)$weight)
 
#再转为其它类型的网络文件，例如
#再由 igraph 的邻接列表转换回邻接矩阵
adj_matrix <- as.matrix(get.adjacency(g, attr = 'sparcc'))
write.table(data.frame(adj_matrix, check.names = FALSE), 'network.adj_matrix.txt', col.names = NA, sep = '\t', quote = FALSE)
 
#graphml 格式，可使用 gephi 软件打开并进行可视化编辑
write.graph(g, 'network.graphml', format = 'graphml')
 
#gml 格式，可使用 cytoscape 软件打开并进行可视化编辑
write.graph(g, 'network.gml', format = 'gml')
 
#边列表，也可以直接导入至 gephi 或 cytoscape 等网络可视化软件中进行编辑
edge <- data.frame(as_edgelist(g))
 
edge_list <- data.frame(
    source = edge[[1]],
    target = edge[[2]],
    weight = E(g)$weight,
    sparcc = E(g)$sparcc
)
head(edge_list)
 
write.table(edge_list, 'network.edge_list.txt', sep = '\t', row.names = FALSE, quote = FALSE)
 
#节点属性列表，对应边列表，记录节点属性，例如
node_list <- data.frame(
    nodes_id = V(g)$name,    #节点名称
    degree = degree(g)    #节点度
)
head(node_list)
 
write.table(node_list, 'network.node_list.txt', sep = '\t', row.names = FALSE, quote = FALSE)

```

g 是igrah的无向网络，可以 plot(g) 得到网络图，但是很不美观

有两种解决方案
一是使用R美化网络，二是使用软件如cytoscape、Gephi。

```R


```