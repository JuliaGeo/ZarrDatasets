using ZarrDatasets
using ZarrDatasets:
    defDim,
    defVar

data = rand(Int32,3,5)

fname = tempname()
mkdir(fname)
gattrib = Dict{String,Any}("title" => "this is the title")
ds = ZarrDataset(fname,"c",attrib = gattrib)

defDim(ds,"lon",3)
defDim(ds,"lat",5)

attrib = Dict{String,Any}(
    "units" => "m/s",
    "long_name" => "test",
)


varname = "var2"
dimensionnames = ("lon","lat")
vtype = Int32

zv = defVar(ds,varname,vtype,dimensionnames, attrib = attrib)
zv[:,:] = data
zv.attrib["lala"] = 12
zv.attrib["standard_name"] = "test"
ds.attrib["history"] = "test"
close(ds)

ds = ZarrDataset(fname)

zv = ds[varname]

@test zv.attrib["lala"] == 12
@test zv.attrib["standard_name"] == "test"
@test ds.attrib["history"] == "test"

@test zv[:,:] == data

io = IOBuffer()
show(io,ds)
str = String(take!(io))
@test occursin("Global",str)


# fill value

fname = tempname()
ds = ZarrDataset(fname,"c")
defDim(ds,"lon",100)
v = defVar(ds,"lon",Float32,("lon",),fillvalue = 9999.)
v .= 1
close(ds)

ds = ZarrDataset(fname)
@test eltype(ds["lon"]) ==  Union{Missing, Float32}
@test eltype(cfvariable(ds,"lon",fillvalue=nothing)) == Float32
