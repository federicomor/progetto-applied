using GLM, CSV, IterTools
using StatsModels, DataFrames
using Pingouin

############# Scoial well being #############
# df = DataFrame(CSV.File("../../data/pisa_scores_final.csv"))
# covariate_fit = [
# 	"Approach to ICT"
# 	"Use of ICT"
# 	"Teachers' degree"
# 	"Teacher skill"
# 	# # "ESCS"
# 	"RATCMP1"
# 	"ICTSCH"
# 	# # "ICTRES"
# 	# # "ENTUSE"
# 	# # "LM_MINS"
# 	"HEDRES"
# 	# # "STUBEHA"
# 	"ATTLNACT"
# 	# # "JOYREAD"
# 	# # "PROAT6"
# 	# # "TEACHBEHA"
# 	# # "STRATIO"
# 	"CLSIZE"
# 	# # "EDUSHORT"
# 	"STAFFSHORT"
# 	"PV1MATH"
# 	"PV1READ"
# 	"CREACTIV"
# 	# "CNT"
# 	# # "SCHLTYPE"
# 	# # "Social well-being"
# 	# # "Psychological well-being"
# 	]
Ytarget = "Psychological well-being" 

df = DataFrame(CSV.File("data_woo.csv"))
covariate_fit=[
	"Approach.to.ICT"  
	"Use.of.ICT"       
	"Teachers..degree" 
	"Teacher.skill"   
	"ESCS"             
	"RATCMP1"          
	"ICTSCH"           
	"HEDRES"          
	"STUBEHA"          
	"ATTLNACT"         
	"JOYREAD"          
	"PROAT6"          
	"CLSIZE"           
	"EDUSHORT"         
	"STAFFSHORT"       
	"PV1MATH"         
	"PV1READ" 
]
Ytarget = "Psychological.well.being"

f1(x) = x
f2(x) = x^2
f3(x) = x^3
f4(x) = exp(-x^2)
f5(x) = cos(x)
f6(x) = sin(x)
f7(x) = abs(x)
f8(x) = log(x+abs(minimum(x))+1)
f9(x) = sqrt(abs(x))

fdict = [
	"U", # f1
	"U^2", # f2
	# "U^3", # f3
	# "exp(-U^2)", # f4
	# "cos(U)", # f5
	# "sin(U)", # f6
	# "abs(U)", # f7
	"log(U+abs(minimum(U))+1)", # f8
	# "sqrt(abs(U))" # f9
]

funzioni = [
	f1 
	f2 
	# f3 
	# f4
	# f5 
	# f6
	# f7
	f8
	# f9
]


println("## Performing random tests ##")
println("Using as covariates:")
for cova in covariate_fit
	println(" :$cova")
end
println("And as functions:")
for fun in fdict
	println(" :$fun")
end
println("")
############# Random tests #############

SOGLIA_PVALUE = 0.85
n_rand_tests = 100_000_000
bestpval = 1e-16

for i in 1:n_rand_tests
	# print("Iteration $i\r")
	global bestpval
	X = ones(size(df)[1])
	# v=digits(i,base=length(funzioni)-1,pad=length(covariate_fit)+1)
	v=rand(1:length(funzioni),length(covariate_fit)+1)
	covariate = covariate_fit
	for j in 1:(length(v)-1)
		X = [X funzioni[v[j]].(df[:,covariate[j]])]
	end
	y=funzioni[v[end]].(df[:,Ytarget])
	
	fit = ""
	pval = ""
	try
		fit=lm(X,y)
		pval = normality(residuals(fit)).pval[1]
	catch e
		@show e
	end
	if(pval>SOGLIA_PVALUE)
		println("\nFound something: ")
		println(pval)
		@show v
		@show fit
		for i in 1:length(covariate_fit)
			println("x$i = ",
				replace(fdict[v[i]],"U"=>"(data_woo\$$(covariate_fit[i]))"))
		end
		println("y = ",replace(fdict[v[end]],"U"=>"(data_woo\$$Ytarget)"))
		
		print("y ~ ")
		for i in 1:length(covariate_fit)
			print("x$i +")
		end
		println("")
	end
		bestpval= max(bestpval,pval)
		i%100==0 && print("Iteration $i | Pvalue: $pval | Min till now pvalue: $bestpval\r")
end