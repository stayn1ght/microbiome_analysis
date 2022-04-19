# Cytoscape3.9.1

## 设置边的颜色

在style - edge中，找到stroke color，选择column为sparcc也就是sparcc计算的分值，Mapping type选择Continuous Mapping也就是渐变色，然后调整颜色即可。

下载工作表格，包括各点的度的表格，以及taxa的表格，将其按逗号分隔，整合到Cytoscape的node table上。具体点就是把cytoscape里面那个table导出，然后用excel把该加的内容加上。

加上sparCC值，边的颜色可以用渐变色表示分值的大小
加上每个点所属的菌门，就可以按照菌门设置点的颜色
加上每个点的度，按照度设置点的大小
在style选项卡右边有一个按钮，点开可以找到添加图例。
最左侧有filter选项卡，用于过滤。目前只过滤掉sparCC值很低的边，再手动删去过滤后没有边相连的点。


可以根据点的度调整点的大小，点的颜色根据点所属的菌门来确定。