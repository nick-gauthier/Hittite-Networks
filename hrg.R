
Hierarchical Random Graph Model

```{r}


hrg <- hrg.fit(mode1)
hrg.con <- hrg.consensus(mode1, hrg=hrg, start=TRUE)
hrg.tree <- hrg.dendrogram(hrg)

plot(hrg.tree, layout = layout.reingold.tilford(hrg.tree), vertex.size = 3, edge.arrow.size=0, vertex.label=names(dat), vertex.label.cex = .8)


dend <- as.dendrogram(hrg.tree, use.modularity=TRUE)

```



```{r}
gplot(dat, gmode = 'twomode', usearrows = F, displayisolates = F, displaylabels = T,label.cex = .5)

gplot(mode1 %>% get.adjacency %>% as.matrix, gmode = 'graph', displayisolates = F, displaylabels = T, label = names(dat), edge.lwd = 1, label.cex = .7)

tapered.arcs(t(dat))
tapered.arcs(mode1 %>% get.adjacency %>% as.matrix)
```

MDS

Try nonmetric multidimensional scaling
```{r}

gplot(mode1.new, gmode = 'graph', displayisolates = F, edge.lwd = 1,
      edge.col=matrix(rgb(0, 0, 0, mode1.new / max(mode1.new)), nrow = dim(mode1.new)[1]), 
      displaylabels = T, label = row.names(dat), mode='mds', label.cex = .7)

mode1.bin.diag1 <- mode1.bin
diag(mode1.bin.diag1) <- 1
d <- 1-mode1.bin.diag1
d[d==0] <- .05

d <- 1/mode1.sum.nozero
d[d==Inf] <- .5   

mode1.sum.nozero <- mode1.sum
mode1.sum.nozero[mode1.sum.nozero == 0] <- .5
d <- sqrt((colSums(mode1.sum) %o% rowSums(mode1.sum)) / mode1.sum.nozero)
d[d==Inf] <- .05
d[is.na(d)] <- .05
d[d==0] <- .05

library(MASS)

fit <- isoMDS(d, k=2)
x <- fit$points[,1]
y <- fit$points[,2]
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2",
     main="Nonmetric MDS",  pch=16, las=1, asp=1)
text(x, y, labels = row.names(dat), cex=.7, pos=3, asp=1)

#coords <- layout_with_mds(mode1.sum, dist = d)
#gplot(mode1.new, gmode = 'graph', displayisolates = F, edge.lwd = 1,
#      edge.col=matrix(rgb(0, 0, 0, mode1.new / max(mode1.new)), nrow = dim(mode1.new)[1]), 
#      displaylabels = T, label = names(dat), layout = coords, label.cex = .7, dist = d)
```


```{r fig.width=10, fig.height=10}
#notrun
#gplot(mode1.new, gmode = 'graph', displayisolates = F, displaylabels = T, label = names(dat), edge.col=matrix(rgb(0, 0, 0, mode1.new / max(mode1.new)), nrow = dim(mode1.new)[1]),      edge.lwd = 1, label.cex = .7, mode = 'target', usecurve = T)
```




devtools::install_github("briatte/ggnet")
library(ggnet)
library(ggplot2)
library(network)
library(sna)
library(grid)

dat <- read.csv('Two Mode-Table.csv', row.names = 1) # import data and use the values in column 1 as row names
dat[is.na(dat)] <- 0  # binarize the network
dat <- t(dat) 

net <- network(dat, matrix.type='bipartite', directed = F)
col = c("actor" = rgb(241,163,64, max = 255), "event" = rgb(153,142,195, max = 255))
shps = c('actor' = 16, 'event' = 15)

# detect and color the mode
ggnet2(net, color = "mode", shape = "mode", size = 'degree', palette = c("actor" = rgb(241,163,64, max = 255), "event" = rgb(153,142,195, max = 255)), shape.palette = c('actor' = 16, 'event' = 15), size.zero = T, edge.lty = 3, edge.color = 'darkgrey', edge.size = .75)
ggnet2(net, color = "mode", shape = "mode", size = 'degree', palette = c("actor" = "black", "event" = "grey60"), shape.palette = c('actor' = 16, 'event' = 15), size.zero = T, edge.lty = 3, edge.color = 'darkgrey', edge.size = .75)
ggnet2(net, color = "mode", size = 'degree', palette = c("actor" = rgb(241,163,64, max = 255), "event" = rgb(153,142,195, max = 255)),size.zero = T, edge.lty = 3, edge.color = 'darkgrey', edge.size = .75)
ggnet2(net, color = "mode", size = 'degree', palette = c("actor" = "black", "event" = "grey60"), size.zero = T, edge.lty = 3, edge.color = 'darkgrey', edge.size = .75)

ggnet2(net, color = "mode", size = 'degree', size.zero = T, edge.lty = 3, edge.color = 'darkgrey', edge.size = .75)

k## Appendix  
#Heres the code going into the function to draw graphs with tapered intensity curves.


library(Hmisc)
library(reshape2)
tapered.arcs <- function(net.in){
# Empty ggplot2 theme
new_theme_empty <- theme_bw()
new_theme_empty$line <- element_blank()
new_theme_empty$rect <- element_blank()
new_theme_empty$strip.text <- element_blank()
new_theme_empty$axis.text <- element_blank()
new_theme_empty$plot.title <- element_blank()
new_theme_empty$axis.title <- element_blank()
new_theme_empty$plot.margin <- structure(c(0, 0, -1, -1), unit = "lines",
valid.unit = 3L, class = "unit")


adjacencyMatrix <-  net.in # data here
layoutCoordinates <- gplot(adjacencyMatrix, gmode = 'twomode', usearrows = F, displayisolates = T)  # Get graph layout coordinates

adjacencyList <- melt(adjacencyMatrix)  # Convert to list of ties only
adjacencyList <- adjacencyList[adjacencyList$value > 0, ]

# Function to generate paths between each connected node
edgeMaker <- function(whichRow, len = 100, curved = TRUE){
fromC <- layoutCoordinates[adjacencyList[whichRow, 1], ]  # Origin
toC <- layoutCoordinates[adjacencyList[whichRow, 2], ]  # Terminus

# Add curve:
graphCenter <- colMeans(layoutCoordinates)  # Center of the overall graph
bezierMid <- c(fromC[1], toC[2])  # A midpoint, for bended edges
distance1 <- sum((graphCenter - bezierMid)^2)
if(distance1 < sum((graphCenter - c(toC[1], fromC[2]))^2)){
bezierMid <- c(toC[1], fromC[2])
}  # To select the best Bezier midpoint
bezierMid <- (fromC + toC + bezierMid) / 3  # Moderate the Bezier midpoint
if(curved == FALSE){bezierMid <- (fromC + toC) / 2}  # Remove the curve

edge <- data.frame(bezier(c(fromC[1], bezierMid[1], toC[1]),  # Generate
c(fromC[2], bezierMid[2], toC[2]),  # X & y
evaluation = len))  # Bezier path coordinates
edge$Sequence <- 1:len  # For size and colour weighting in plot
edge$Group <- paste(adjacencyList[whichRow, 1:2], collapse = ">")
return(edge)
}

# Generate a (curved) edge path for each pair of connected nodes
allEdges <- lapply(1:nrow(adjacencyList), edgeMaker, len = 500, curved = TRUE)
allEdges <- do.call(rbind, allEdges)  # a fine-grained path ^, with bend ^

zp1 <- ggplot(allEdges)  # Pretty simple plot code
zp1 <- zp1 + geom_path(aes(x = x, y = y, group = Group,  # Edges with gradient
colour = Sequence, size = -Sequence))  # and taper
# distinguish between mode type in nodes

zp1 <- zp1 + geom_point(data = data.frame(layoutCoordinates,type = c(rep('tablet', dim(adjacencyMatrix)[1]),rep('site', dim(adjacencyMatrix)[2]))),  # Add nodes
     aes(x = x, y = y, pch = type), size = 5,
     colour = "black", fill = "gray")  # Customize gradient v
zp1 <- zp1 + scale_colour_gradient(low = gray(0), high = gray(9/10), guide = "none")
zp1 <- zp1 + scale_size(range = c(1/10, 1), guide = "none")  # Customize taper
zp1 <- zp1 + new_theme_empty  # Clean up plot
print(zp1)
}
```
