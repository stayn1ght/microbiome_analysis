# use package 'plotly' to draw interactive graph
library(plotly)

## 计算物种的相对丰度的均值与中位数和流行度
### 流行度：物种在多少样本中存在。在样本中某物种相对丰度高于某个阈值，比如0.01%，我们认为这个物种在这个样本中是存在的。

# 流行度计算, 草稿

setwd('/mnt/raid7/mingyuwang/gut_fungus/example_PRJNA751473_ITS/')
feature_table <- read.table("08_table_level6/08_table_level6.tsv", header = F, row.names = 1)
mean_abundance <- apply(feature_table, 1, mean)
mid_abundance <- apply(feature_table, 1, median)
abundance <- data.frame(cbind(mean_abundance, mid_abundance))


bool_table <- feature_table > 10
x <- rowSums(bool_table)
y <- ncol(bool_table)
preva <- x/y

## 用plotly绘制交互式散点图

fig <- plot_ly(data = abundance, x = re, y = ~mean_abundance,  
               type = "scatter", mode = "markers", name = "median")
fig <- fig %>% add_trace(y = ~mid_abundance, name = 'mean', mode = 'markers')
fig
