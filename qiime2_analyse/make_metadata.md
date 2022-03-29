# to make metadata

```shell
mv SraRunTable.txt metadata.csv
```

```R
meta <- read.csv("metadata.csv", header = TRUE)
temp0 <- meta["Run"] # don't change
temp0 <- cbind(temp0, meta["Host_disease"])
colnames(temp0) <- c("sampleid", "phenotype")
write.table(temp0, file = "meta", sep = '\t', row.names = FALSE)
q()

```


```shell
sed -i '1s/$/\t"label"/' meta
sed -i '/DR/ s/$/\t"Diabetic Retinopathy"/' meta
sed -i '/HS/ s/$/\t"healthy"/' meta
sed -i '/T2D/ s/$/\t"type 2 Diabetes"/' meta

```
the file 'meta' is what we need for next steps