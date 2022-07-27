
library(taxonomizr)
library(Biostrings)
library(ggplot2)

projectname<-"COI"
infile=paste0("/share/ScratchGeneral/nenbar/projects/Anthony/scripts/",projectname,"/db/pests.19.fasta")

seqs<-readDNAStringSet(infile)
seqs<-seqs[order(names(seqs))]
#import data from table
annotation<-read.csv("db/MarinePestReferenceDatabase.csv")

df<-data.frame(ids=names(seqs))
df$ids<-gsub("~.*","",df$ids)
df$ids<-gsub("_.*","",df$ids)

merged<-merge(df,annotation,by.x="ids",by.y="Sample.ID",sort=F,all.x=T)


#plot widths
pdf("amplicon_width_pests.19.pdf",width=6,height=4)
qplot(width(seqs))+geom_histogram()+xlab("Amplicon width")
dev.off()

#convert all the ids to taxonomy
#seqsS<-seqs
#ids<-names(seqsS)
ids<-merged$Species.Name
idsClean<-gsub(" $","",ids)

#fix the names
idsClean[1]<-"Dreissena rostriformis bugensis"
idsClean[19:23]<-"Codium fragile"
idsClean[117]<-"Pinctada albina"
idsClean[124:125]<-"Caulerpa cylindracea"
idsClean[126]<-"Pinctada albina"
idsClean[c(139,141)]<-"Oestridae sp."

#fix 86


prepareDatabase('accessionTaxa.sql')


taxaId<-getId(idsClean,sqlFile="accessionTaxa.sql")

taxaId[86]=2848398
taxaId[89]=1835367
taxaId[126]=2559386
taxaId[138]=1906867
taxaId[139]=123734
taxaId[141]=123734
taxaId[142]=2486932
taxaId[143]=2486932
taxaId[146]=1295088

taxa<-getTaxonomy(taxaId,'accessionTaxa.sql',desiredTaxa = c("kingdom", "phylum", "class", "order", "family", "genus",
         "species"))

#fix 89 by hand Charybdis yaldwyni
taxa[89,"species"]="Charybdis yaldwyni"
#fix 126 by hand to Nectocarcinus antarcticus
taxa[126,"species"]="Nectocarcinus antarcticus"
#fix 138 by hand to Brachidontes sp.
taxa[138,"species"]="Brachidontes sp."
#fix 139,141 by hand to Oestridae sp.
taxa[c(139,141),"species"]="Oestridae sp."

#fix 142 to Xiphonectes rugosus
taxa[142,"species"]="Xiphonectes rugosus"
#fix 143 to Xiphonectes hastatoides
taxa[143,"species"]="Xiphonectes hastatoides"
#fix 146 to Monomia curvipenis
taxa[146,"species"]="Monomia curvipenis"

tmp=taxa
row.names(tmp)<-1:dim(tmp)[1]


table(taxa[,2])
seqNames<-paste0(
	taxa[,"species"],"-",idsClean,
	";tax=k:",taxa[,"kingdom"],
	",p:",taxa[,"phylum"],
	",c:",taxa[,"class"],
	",o:",taxa[,"order"],
	",f:",taxa[,"family"],
	",g:",taxa[,"genus"],
	",s:",taxa[,"species"],
	"-",idsClean)
seqNames<-gsub(" ","-",seqNames)


names(seqs)<-seqNames
writeXStringSet(seqs,"pests.19.taxed.fasta",format="fasta")








	