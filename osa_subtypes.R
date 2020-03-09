#### Latent class analysis for identification of OSA symptom subtypes
#### Diego Mazzotti
#### March 2020
#### Custom function

#### Usage:
#### osa_subtypes(data="sample_data.csv", project_name="SampleProject", k_n=1:4)

library(dplyr)
library(poLCA)
library(ggplot2)
library(reshape2)
library(tidyr)
library(gplots)

osa_subtypes <- function(input_f=NULL,
                         project_name=NULL,
                         k_n=1:4,
                         custom_row_labels=NULL,
                         custom_col_labels=NULL,
                         save.model=T) {
        
        # Initial argument checking
        
        if(is.null(input_f)) {stop("Error: Please provide dataset in csv format")}
        if(is.null(project_name)) {stop("Error: Please provide a name for your project")}
        if(!is.integer(k_n)) {stop("Error: Please provide number of cluster solutions to test in integer format")}
        
        #### Part 1: Load data and check data
        # Load processed data
        data <- read.csv(input_f, stringsAsFactors = F)
        
        if(colnames(data)[1]!="SampleID") {
                
                stop("Error: first column is not named 'SampleID'. Please check.")
        }
        
        
        #### Part 2: Check for excessive missing data
        # TO DO
        
        #### Part 3: Run LCA
        LCAresults <- list()
        for (k in k_n) {
                set.seed(1234)
                LCAresults[[paste0("LCA_", k)]] <- poLCA(as.matrix(dplyr::select(data, -SampleID)) ~ 1, maxiter=10000, nclass = k, nrep=75, data=dplyr::select(data, -SampleID), na.rm=F, graphs = F)
        }
        
        if(save.model) {saveRDS(LCAresults, paste0("LCAresults_",project_name,".Rdata"))}
        
        
        #### Part 4: BIC plot
        
        # Get BIC values
        bic_results <- sapply(LCAresults, "[[", "bic")
        
        # And plot them
        pdf(paste0("Scree_plot_of_BIC_",project_name,".pdf"))
        p <- ggplot(data=data.frame(BIC=bic_results), aes(x=k_n, y=BIC, group=1)) +
                geom_line() +
                geom_point() + 
                scale_x_continuous(breaks = k_n) + 
                theme_bw() +
                xlab("Cluster solution (K)")
        p
        dev.off()
        
        # Get cluster membership for all cluster definitions
        LCA_membership_df <- as.data.frame(sapply(LCAresults, "[[", "predclass"))
        
        # Add id column
        LCA_membership_df <- data.frame(SampleID=data$SampleID, LCA_membership_df, stringsAsFactors = F)
        
        # Merge symptoms_clean with LCA_membership_df by id:
        symptoms_with_LCAresults_df <- merge(data, LCA_membership_df, by = "SampleID")
        
        # Save
        write.csv(symptoms_with_LCAresults_df, paste0("LCAResults_",project_name,".csv"), row.names = F)
        
        
        #### Part 5: Create heatmaps
        # Set names of clusters to iterate
        LC_names <- names(LCAresults)[-1] # not meaningful for 1 cluster
        
        # Get symptom variable names
        symps <- colnames(data)[!colnames(data) %in% "SampleID"]
        
        # Create heatmaps
        i=1
        for (LC_n in LC_names) {
                
                melt_df <- melt(symptoms_with_LCAresults_df, measure.vars = symps)
                
                c_idx <- i+4
                
                res <- melt_df %>%
                        group_by_(LC_n, "variable", "value") %>%
                        summarise (n = n()) %>%
                        filter(!is.na(value)) %>%
                        mutate(freq = n / sum(n, na.rm = T)) %>%
                        filter(value==2 | value==3 | value==4) %>%
                        #filter(!is.na(freq)) %>%
                        #drop_na() %>%
                        dplyr::select(LC_n, variable, value, freq) %>%
                        spread(LC_n, freq) %>%
                        mutate(variable_name=paste0(variable, "_", value)) %>%
                        ungroup() %>%
                        dplyr::select(variable_name, everything()) %>%
                        dplyr::select(c(1,4:c_idx)) %>%
                        replace(., is.na(.), 0)
                
                syms <- as.data.frame(res[,-1])
                
                rownames(syms) <- res$variable_name
                colnames(syms) <- paste0("Cluster_", colnames(syms))
                
                syms.break<-c(0,seq(0.05,1.0,0.05))
                
                cellnote<-round(100*syms,2)
                
                cellnote[1:nrow(cellnote),]<-round(100*syms[1:nrow(syms),],1)
                
                cellnote[1:nrow(cellnote),] <- data.frame(sapply(cellnote[1:nrow(cellnote),], format, digits=3, justify="none"), stringsAsFactors = F)
                cellnote[1:nrow(cellnote),] <- sapply(cellnote[1:nrow(cellnote),], paste0, "%")
                
                
                
                png(paste0(LC_n, "_clusters_", project_name, ".png"), height=3600, width=3200)
                heatmap.2(as.matrix(syms), Rowv=F, scale="row", Colv=F, dendrogram="none", keysize=2.25, cellnote=cellnote, notecol='white',
                          density.info="none", trace="none", cexRow=6.75, cexCol=6.9, notecex=6.75, colsep=(c(1,2,3)), sepwidth=c(0.05,0.05),
                          col=c(colorRampPalette(c("grey",  "red3"))(100)), margins=c(24,90), srtCol=0, adjCol=c(0.5,1.0),
                          key=T, key.title=NA, key.par=list(cex=3.9), lmat = rbind(c(0,3),c(2,1),c(0,4)), lwid = c(1.5,5), lhei = c(0.25,5.25,0.7), main = )
                
                
                dev.off()
                
                i=i+1
                
                
        }
        
        
        
        
}

