### Network Graph

# Install and load the igraph package
install.packages("igraph", dependencies = TRUE)
library(igraph)

# Load the data. The data needs to be loaded as a table first: 
bsk <- read.table("http://www.dimiter.eu/Data_files/edgesdata3.txt", sep='\t', 
                dec=',', header=T)

# Transform the table into the required graph format:
bsk.network <- graph.data.frame(bsk, directed=F)    # the 'directed' attribute specifies whether the edges are directed

# or equivelent irrespective of the position (1st vs 2nd column). For directed graphs use 'directed=T'
bad.vs <- V(bsk.network)[degree(bsk.network)<3]     # identify those vertices part of less than three edges
bsk.network <- delete.vertices(bsk.network, bad.vs) # exclude them from the graph

# Plot the data.Some details about the graph can be specified in advance.
# For example we can separate some vertices (people) by color:
V(bsk.network)$color <- ifelse(V(bsk.network)$name=='CA', 'blue', 'red') #useful for highlighting certain people. Works by matching the name attribute of the vertex to the one specified in the 'ifelse' expression

# We can also color the connecting edges differently depending on the 'grade': 
E(bsk.network)$color <- ifelse(E(bsk.network)$grade==9, "red", "grey")

# or depending on the different specialization ('spec'):
E(bsk.network)$color <- ifelse(E(bsk.network)$spec=='X', "red", ifelse(E(bsk.network)$spec=='Y', "blue", "grey"))
V(bsk.network)$size <- degree(bsk.network)/10#here the size of the vertices is specified by the degree of the vertex, so that people supervising more have get proportionally bigger dots. Getting the right scale gets some playing around with the parameters of the scale function (from the 'base' package)

# And finally the plot itself:
par(mai=c(0,0,1,0)) 			            # this specifies the size of the margins. the default settings leave too much free space on all sides (if no axes are printed)
plot(bsk.network,				            # the graph to be plotted
     layout=layout.fruchterman.reingold,	# the layout method. see the igraph documentation for details
     main='Organizational network example',	# specifies the title
     vertex.label.dist=0.5,			        # puts the name labels slightly off the dots
     vertex.frame.color='blue', 		    # the color of the border of the dots 
     vertex.label.color='black',		    # the color of the name labels
     vertex.label.font=2,			        # the font of the name labels
     vertex.label=V(bsk.network)$name,		# specifies the lables of the vertices. in this case the 'name' attribute is used
     vertex.label.cex=1			            # specifies the size of the font of the labels. can also be made to vary
)
