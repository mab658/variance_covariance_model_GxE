
# A defined function latentPlot for latent regression plot
latentRegPlot <- function(xval, yval,xlab, ylab){
  plt <- ggplot(data=genplot,aes(x=xval, y=yval, colour=gen))+ geom_point(aes(shape=gen)) +
    stat_smooth(method="lm",formula = y ~ x,se=FALSE)+
    labs(x=xlab, y=ylab)+ 
    theme_bw() +
    theme(plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(size = 7, face="bold", hjust = 0.5),
          axis.text.y = element_text(size = 7, face="bold",hjust = 0.5, angle = 90),
          axis.title.y = element_text(size = 10, face = "bold"),
          axis.title.x = element_text(size = 10, face = "bold"),
          legend.position = "none") +
    
    facet_wrap(.~gen, nrow=3,scales = "fixed")+
   theme(strip.text = element_text(
    size = 12, color = "black"))
  return(plt)
}