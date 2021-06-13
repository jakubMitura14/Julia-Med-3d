```@doc
functions responsible for helping in image viewer - those functions are  meant to be invoked on separate process
- in parallel
```
using DrWatson
@quickactivate "Probabilistic medical segmentation"

module imageViewerHelper
using Base: Number
using Documenter
export calculateMouseAndSetmask
export createMedicalImageColorScheme
# using AbstractPlotting
```@doc
  given mouse event modifies mask accordingly
  maskArr - the 3 dimensional bit array  that has exactly the same dimensions as main Array storing image 
  dims - dimensions of a mask
  sliceNumb - number of sclice that is currently displaying
  xMouse - x coordinate where we clicked
  yMouse - y coordinate where we clicked
  return modified mask array where we added data  where we clicked
  ```
function calculateMouseAndSetmask(maskArr,dims::Tuple{Int64, Int64, Int64},sliceNumb::Number,xMouse::Number,yMouse::Number )  
  #position from top left corner 

  #data about height and width in layout
  compBoxWidth = 510 
  compBoxHeight = 510 
  #image dimensions - number of pixels  from medical image for example ct scan
  pixelsNumbInX =dims[1]
  pixelsNumbInY =dims[2]
  #calculating over which image pixel we are
  calculatedXpixel =convert(Int32, round( (xMouse/compBoxWidth)*pixelsNumbInX) )
  calculatedYpixel =  convert(Int32,round( (yMouse/compBoxHeight)*pixelsNumbInY ))
  sliceNumbConv =convert(Int32,round( sliceNumb[] ))
  #appropriately modyfing wanted pixels in mask array
  pixelLoc = CartesianIndex(calculatedXpixel, calculatedYpixel, sliceNumbConv  )
  patchSize = 2
  prim = cartesianCoordAroundPoint(pixelLoc,patchSize)
  a = map((c->cartesianCoordAroundPoint(c,patchSize)),prim)
  b = Iterators.flatten(a)
  c = collect(b)
  d=  unique(c)
  #widerInd = unique ∘ collect ∘  Iterators.flatten ∘ Iterators.flatten ∘ map((c->cartesianCoordAroundPoint(c,patchSize)),cartesianCoordAroundPoint(pixelLoc,patchSize) ) 
  static = maskArr[]
  imageDim = size(static)
  e= static[d].=3
  f= e[prim].=5
  g= f[pixelLoc]=7
  # markMaskArrayPatchTo!( static,pixelLoc,patchSize,5)
  return g
end



```@doc
  maskArr - the 3 dimensional bit array  that has exactly the same dimensions as main Array storing image 
  point - cartesian coordinates of point around which we want to modify the 3 dimensional array from 0 to 1
  modifies mask array
  valueToSet - the new value by whic we will modify 
  return modified array 
```
function markMaskArrayPatchTo!(maskArr, pointCart::CartesianIndex{3}, patchSize ::Int,valueToSet,imageDim )
  
  filter((ind) -> arra[ind] == 0.5, CartesianIndices(arra))
return maskArr[cartesianCoordAroundPoint(pointCart,patchSize)]=valueToSet
end

```@doc
  point - cartesian coordinates of point around which we want the cartesian coordeinates
  return set of cartetian coordinates of given distance -patchSize from a point
```
function cartesianCoordAroundPoint(pointCart::CartesianIndex{3}, patchSize ::Int)
  ones = CartesianIndex(patchSize,patchSize,patchSize) # cartesian 3 dimensional index used for calculations to get range of the cartesian indicis to analyze
  out = Array{CartesianIndex{3}}(UndefInitializer(), 6+2*patchSize^4)
  index =0
  for J in (pointCart-ones):(pointCart+ones)
    diff = J - pointCart # diffrence between dimensions relative to point of origin
      if cartesianTolinear(diff) <= patchSize
        index+=1
        out[index] = J
      end
      end
return out[1:index]
end






```@doc
works only for 3d cartesian coordinates
  cart - cartesian coordinates of point where we will add the dimensions ...
```
function cartesianTolinear(pointCart::CartesianIndex{3}) :: Int16
   abs(pointCart[1])+ abs(pointCart[2])+abs(pointCart[3])
end





end #module