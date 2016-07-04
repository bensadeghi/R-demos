### rxExec - Generate the Mandelbrot Set
### Demonstrate parallelization of a user-defined function using rxExec()

# Load ScaleR Package
library(RevoScaleR)

# Mandelbrot user-defined function
mandelbrot <- function(x0, y0, lim) {
    x <- x0; y <- y0
    iter <- 0
    while (x^2 + y^2 < 4 && iter < lim) {
        xtemp <- x^2 - y^2 + x0
        y <- 2 * x * y + y0
        x <- xtemp
        iter <- iter + 1
    }
    iter
}

# Helper function which returns a vector of results for a given y value
vmandelbrot <- function(xvec, y0, lim) {
    unlist(lapply(xvec, mandelbrot, y0=y0, lim=lim))
}

# Define x and y axis intervals and resolution
npix <- 480
x.in <- seq(-2.0, 0.6, length.out=npix)
y.in <- seq(-1.3, 1.3, length.out=npix)    

# Distributed execution of vmandelbrot function, iterated 100 times,
# passing 1/10 of tasks to each available compute element
niterations <- 100
z <- rxExec(vmandelbrot, x.in, y0=rxElemArg(y.in), niterations,
	taskChunkSize=npix/10, execObjects="mandelbrot")    

# Transform vector to matrix and display as image
z <- matrix(unlist(z), ncol=npix)
image(x.in, y.in, z, col=c(rainbow(npix), '#000000'), useRaster=TRUE)
