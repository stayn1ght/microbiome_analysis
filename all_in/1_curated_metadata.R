library(dplyr)
metadata <- read.csv("curated_metadata.csv")
mesh.id <- data.frame(c("atopic", "healthy", "IBS", "COVID-19", "Diabetic Retinopathy", "type 2 Diabetes", "Alzheimer disease",
                       "NAFLD", "healthy control", "NAFL", "NASH", "type 1 diabetes"
                       ),
                      c("D003876", "D006262", "D043183", "D000086382", "D003930", "D003924", "D000544",
                        "D065626", "D006262", "D065626", "D065626", "D003922"
                       )
                      )
colnames(mesh.id) <- c("phenotype", "disease")
mesh.id <- bind_rows(phenotype = c("CD", "Nrml"), disease = c("D003424", "D006262")) # 为了避免可能存在的冲突，也就是不同项目同样的简称对应不同的

# the code above needs to be changed in the future.
##### change ---------

##### for each project
metadata.with.mesh <- left_join(select(metadata, -disease), mesh.id, by="phenotype")
write.csv(metadata.with.mesh, file="curated_metadata.csv") # new table with mesh id
## then we can extract some information from this file
meta <- select(metadata.with.mesh, sampleid = run_id, disease) # disease are MeSH ids.
write.table(meta, file = "meta", row.names = FALSE) # this file can be used to qiime2 analysis and LEfSe, they both take the tabulate separated file.
