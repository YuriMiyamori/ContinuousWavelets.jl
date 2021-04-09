using ContinuousWavelets, Plots, Wavelets, FFTW,Logging
global_logger(SimpleLogger(min_level=Logging.Error))
global_logger(Logging.SimpleLogger(stderr,Logging.Error))
n=2047;
f = testfunction(n, "Doppler");
testfunction
p1=plot(f,legend=false,title="Doppler",xlims=(0,2000))
c = wavelet(Morlet(π), averagingType=NoAve(), β=6);
res = cwt(f, c)
p2=heatmap(abs.(res)', xlabel= "time index", ylabel="frequency index",colorbar=false)
l=@layout [a{.3h};b{.7h}]
plot(p1,p2,layout=l);
savefig("doppler.svg");#hide
DEFAULT_BOUNDARY; supertype(typeof(morl))
a,b=computeWavelets(n,c)
heatmap(a)
using LaTeXStrings
dRate = 4
waveType = Morlet()
Ψ1 = wavelet(waveType, s=8, β =dRate, averagingLength=2)
# sketch of how the frequencies are chosen
pyplot()
locs = ContinuousWavelets.polySpacing(8,Ψ1);
#Figure 3.1
scatter(1:length(locs), locs, legend=:bottomright, label="mean log frequency", xlabel="Wavelet Index (x)", ylabel= "log-Frequency (y)", color=:black)
scatter!(length(locs):length(locs), locs[end:end], markersize=10, markershape=:x, color=:black, label=:none)
firstW, lastW, stepS = ContinuousWavelets.genSamplePoints(8,Ψ1)
b = (dRate/Ψ1.Q)^(1 ./dRate)*(8+Ψ1.averagingLength)^((dRate-1)/dRate)
t= range(1,stop=length(locs),step=.1)
curve = b .*(range(firstW,stop=(locs[end]/b)^dRate,length=length(t))).^(1 / dRate)
plot!(t, curve, color=:blue, line=:dash, label=L"y=a(mx+x_0)^{^1/_\beta}", legend=:bottomright, legendfontsize=12, xrange=(0,length(locs)+3), xticks= [1; 5:5:1+length(locs)...], yrange=(minimum(locs)-1, maximum(locs)+1), yticks=(range(floor(Int,minimum(locs)), ceil(Int,maximum(locs)),step=2),[L"\alpha", (4:2:8)..., "N.Octaves"]))
x = range(15, stop=28, step=.5)
ycord(x)= locs[end] .+ b/dRate*24 .^(1/dRate-1).*(x .-length(locs))
plot!(x, ycord(x), c=:black,line=2,label=:none)
annotate!(length(locs)-1/8, locs[end]+7.5/16, Plots.text(L"\frac{dy}{dx}=^{1}/_{Q}", 11, :black, :center))
savefig("plotOfLogCentralFrequencies.svg")

n=2047
Ψ1 = wavelet(morl, s=8, β=1)
d1, ξ = computeWavelets(n,Ψ1)
Ψ2 = wavelet(morl, s=8, β =2)
d2, ξ = Wavelets.computeWavelets(n,Ψ2)
Ψ4 = wavelet(morl, s=8, β =4)
d4, ξ = Wavelets.computeWavelets(n,Ψ4)
matchingLimits = (minimum([d1 d2 d4]), maximum([d1 d2 d4]))# for
plot(heatmap(1:size(d1,2), ξ, d1, color=:Greys,
             yaxis = (L"\omega", ),
             xaxis = ("wavelet index", ),
             title=L"\beta=1"*" ("*L"\Psi1"*")", colorbar=false,
             clims=matchingLimits),
     heatmap(1:size(d2,2), ξ, d2, color=:Greys,
             yticks=[],
             xaxis = ("wavelet index", ),
             title=L"\beta=2"*" ("*L"\Psi2"*")", colorbar=false,
             clims=matchingLimits),
     heatmap(1:size(d4,2), ξ, d4,color=:Greys, yticks=[],
             xaxis = ("wavelet index", ),
             title=L"\beta=4"*" ("*L"\Psi4"*")"),
     layout=(1,3),  clims=matchingLimits,
     colorbar_title=L"\widehat{\psi_i}")#hide

savefig("changeBeta.png")
aasdf = randn(10,10)
plot(aasdf, aspect_ratio=1.0)
plot(aasdf)
l=@layout [grid(4,3) [a{.5w};b{.5w};c{.5w};d{.5w}]]
ps = [heatmap(i*j*rand(10,10),colorbar=false) for i=1:4,j=1:4]
plot(ps...,layout=l,size=(1100,800))
Q=8
eval(:Q)

using ContinuousWavelets, Plots, Wavelets, FFTW, Logging
using Plots; gr()
Plots.reset_defaults()
global_logger(Logging.SimpleLogger(stderr,Logging.Error))
n= 2047;
function mapTo(waveType, isReal=true,window=1:2047; d=1, kwargs...)
	if isReal
		c = wavelet(waveType; β=d, kwargs...)
		waves,ω = computeWavelets(n,c)
		return circshift(irfft(waves,2*n,1),(1024,0))[window,:]
	else
		c = wavelet(waveType; β=d, kwargs...)
		waves,ω = computeWavelets(n,c)
        waves = cat(waves, zeros(2047,size(waves,2)),dims=1)
		return circshift(ifft(waves,1),(1024,0))[window,:]
	end
end
tmp = mapTo(Morlet(π),false;averagingLength=-0.2)[:,2]
p1=plot([real.(tmp) imag.(tmp)], title="Morlet", labels=["real" "imaginary"], ticks=nothing,linewidth=5)
tmp = mapTo(paul2,false,averagingLength=-.5)[:,2]
p2=plot([real.(tmp) imag.(tmp)],title="Paul 2", labels=["real" "imaginary"],ticks=nothing,linewidth=5)
p3=plot(mapTo(dog2;averagingLength=-1.5)[:,2],title="derivative of gaussians (dog2)",legend=false,ticks=nothing,linewidth=5)
p4=plot(mapTo(cHaar)[:,2],title="Haar",legend=false,ticks=nothing,linewidth=5)
p5=plot(mapTo(cBeyl, true; d=1, averagingLength=-0)[:,2], title="Beylkyin", legend=false, ticks=nothing, linewidth=5)
p6=plot(mapTo(cVaid, true; d=1, averagingLength=-0)[:,2], title="Vaidyanthan", legend=false, ticks=nothing, linewidth=5)
p7=plot(mapTo(cDb2;d=1,averagingLength=-0)[:,1],title="Daubhechies 2",legend=false,ticks=nothing,linewidth=5)
p8=plot(mapTo(cCoif2, true;d=1, averagingLength=-0)[:,2],title="Coiflet 2",legend=false,ticks=nothing,linewidth=5)
p9=plot(mapTo(cSym4, true; d=1,averagingLength=-0)[:,2],title="Symlet 4",legend=false,ticks=nothing,linewidth=5)
p10=plot(mapTo(cBatt4, true;d=1,averagingLength=-1)[:,2],title="Battle-Lemarie, 4",legend=false,ticks=nothing,linewidth=5)
plot(p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,layout=(2,5),size=300 .*(5, 2.2))
savefig("mothers.svg")#hide


c = wavelet(Morlet(π), averagingType=NoAve(), β=2);
exs = cat(testfunction(n, "Doppler"),testfunction(n,"Blocks"),testfunction(n,"Bumps"),testfunction(n,"HeaviSine"),dims=2)
res = cwt(exs, c)
p1=plot(plot(exs[:,1],legend=false,title="Doppler",yticks=[],xticks=[]), plot(exs[:,2],legend=false,title="Blocks",yticks=[],xticks=[]), plot(exs[:,3],legend=false,title="Bumps",yticks=[],xticks=[]), plot(exs[:,4],legend=false,title="HeaviSine",yticks=[],xticks=[]),layout=(1,4))
c = wavelet(cDb2, β=2,extraOctaves=-0);
res = cwt(exs, c)
p2=plot(heatmap(identity.(res[:,:,1])', xlabel= "time", xticks=false,yticks=[], c=:viridis, colorbar=false), heatmap(identity.(res[:,:,2])', xlabel= "time", xticks=false,yticks=[], c=:viridis, colorbar=false), heatmap(identity.(res[:,:,3])', xlabel= "time", xticks=false,yticks=[], c=:viridis, colorbar=false), heatmap(identity.(res[:,:,4])', xlabel= "time", xticks=false,yticks=[], c=:viridis, colorbar=false), layout=(1,4))
l=@layout [a{.3h};b{.7h}]
plot(p1,p2,layout=l)
savefig("multiEx.svg")
ContinuousWavelets.getNOctaves(n,wavelet(cCoif2))
log2(n)
n/2
c = wavelet(cCoif2,β=1,Q=1)
wave,ω = ContinuousWavelets.computeWavelets(n, wavelet(cCoif4,β=1,Q=1);space=true)
i=1; count(abs.(wave[:,i])/norm(wave[:,i]) .> 1e-7)
plot(wave[1000:1090,end])
ContinuousWavelets.calcDepth(c,n)
log2(n)
log2(length(qmf(c.waveType)))
log2(n)




gr()
n=2047
Ψ1 = wavelet(morl, s=8, β=1)
d1, ξ = computeWavelets(n,Ψ1)
Ψ2 = wavelet(morl, s=8, β =2)
d2, ξ = Wavelets.computeWavelets(n,Ψ2)
Ψ4 = wavelet(morl, s=8, β =4)
d4, ξ = Wavelets.computeWavelets(n,Ψ4)
matchingLimits = (minimum([d1 d2 d4]), maximum([d1 d2 d4]))# for 
plot(heatmap(1:size(d1,2), ξ, d1, color=:Greys, 
             yaxis = (L"\omega", ), 
             xaxis = ("wavelet index", ),
             title=L"\beta=1"*" ("*L"\Psi1"*")", colorbar=false,
             clims=matchingLimits),
     heatmap(1:size(d2,2), ξ, d2, color=:Greys, 
             yticks=[], 
             xaxis = ("wavelet index", ),
             title=L"\beta=2"*" ("*L"\Psi2"*")", colorbar=false,
             clims=matchingLimits), 
     heatmap(1:size(d4,2), ξ, d4,color=:Greys, yticks=[],
             xaxis = ("wavelet index", ),
             title=L"\beta=4"*" ("*L"\Psi4"*")"),
     layout=(1,3),  clims=matchingLimits, 
     colorbar_title=L"\widehat{\psi_i}")
