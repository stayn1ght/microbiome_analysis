# to make metadata

```shell
# delete 16S items
# sed '/16S/d' metadata.csv | cat > metadata.csv 这个语句无论如何都会得到一个空的metadata.csv
cp SraRunTable.txt  ./metadata.csv
sed -i '/V3-V4/d' metadata.csv

```

```R
meta <- read.csv("metadata.csv", header = TRUE)
temp0 <- meta["Run"] # don't change
# temp0 <- cbind(temp0, meta["Host_disease"])
# colnames(temp0) <- c("sampleid", "phenotype")
write.table(temp0, file = "meta", sep = '\t', row.names = FALSE)
q()

```


```shell
sed -i '1s/$/\t"label"/' meta # don't change, and con't run it twice
sed -i '/DR/ s/$/\t"Diabetic Retinopathy"/' meta
sed -i '/HS/ s/$/\t"healthy"/' meta
sed -i '/T2D/ s/$/\t"type 2 Diabetes"/' meta

```
the file 'meta' is what we need for next steps