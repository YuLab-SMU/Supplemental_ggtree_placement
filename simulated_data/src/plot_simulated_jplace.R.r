library(peakRAM)
library(treeio)
library(ggplot2)


jp_list <- list.files("../simulated_jplace")
length(jp_list)

df <- data.frame()

for(j in 1:10){
    for (i in jp_list) {
   filename <- paste0("../simulated_jplace/",i)
   t1 <- peakRAM(test_jp <- read.jplace(filename))
   t1$test_rep <- j
   df <- rbind(df,t1)
   print(filename)
   Sys.sleep(10)
   }
}

df$filename <- jp_list
df$Num_TreeTips <- gsub("tips","",unlist(lapply(df$filename, function(x){unlist(strsplit(x,split="_"))[2]})))
df$Num_Placement <- as.numeric(gsub("jplace","",unlist(lapply(df$filename, function(x){unlist(strsplit(x,split="_"))[5]}))))

write.csv(df,file="./peakRAM.csv",row.names=F)


head(df)

p1 <- df %>%
  group_by(Num_TreeTips,Num_Placement) %>%
  summarise(mean=mean(Peak_RAM_Used_MiB),
    se = sqrt(var(Peak_RAM_Used_MiB)/length(Peak_RAM_Used_MiB)),
            .groups = 'drop') %>% 
  ggplot(aes(Num_Placement,mean)) +
  geom_line(aes(group = Num_TreeTips,color=Num_TreeTips))+
  geom_point(size=1,aes(color=Num_TreeTips),alpha=0.5)+
  geom_errorbar(aes(ymin = mean-se,ymax =mean+se,
                    group = Num_TreeTips,color=Num_TreeTips),
                width = 0.05)+
    theme_light()+
    scale_x_log10() + 
    ylab("Peak_RAM_Used (MiB)")

p2 <- df %>%
  group_by(Num_TreeTips,Num_Placement) %>%
  summarise(mean=mean(Elapsed_Time_sec),
    se = sqrt(var(Elapsed_Time_sec)/length(Elapsed_Time_sec)),
            .groups = 'drop') %>% 
  ggplot(aes(Num_Placement,mean)) +
  geom_line(aes(group = Num_TreeTips,color=Num_TreeTips))+
  geom_point(size=1,aes(color=Num_TreeTips),alpha=0.5)+
  geom_errorbar(aes(ymin = mean-se,ymax =mean+se,
                    group = Num_TreeTips,color=Num_TreeTips),
                width = 0.05)+
    theme_light()+
    scale_x_log10() + 
    ylab("Elapsed_Time(Sec)")

p2+p1
ggsave(filename="../../pdf/FigureS1.pdf",width=12,height=6)

