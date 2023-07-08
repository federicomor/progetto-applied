using GLM, CSV, IterTools
using StatsModels, DataFrames
using Pingouin

############# Scoial well being #############
df = DataFrame(CSV.File("../../data/pisa_scores_final.csv"))
covariate_fit = [
	"Approach to ICT"
	"Use of ICT"
	"Teachers' degree"
	"Teacher skill"
	# "ESCS"
	"RATCMP1"
	"ICTSCH"
	# "ICTRES"
	# "ENTUSE"
	# "LM_MINS"
	"HEDRES"
	# "STUBEHA"
	"ATTLNACT"
	# "JOYREAD"
	# "PROAT6"
	# "TEACHBEHA"
	# "STRATIO"
	"CLSIZE"
	# "EDUSHORT"
	"STAFFSHORT"
	"PV1MATH"
	"PV1READ"
	"CREACTIV"
	# "CNT"
	# "SCHLTYPE"
	# "Social well-being"
	# "Psychological well-being"
	]
 
# formula_str = "\"Psychological well-being\" ~ "
# iter=1
# for cova in covariate_fit
# 	global formula_str, iter
# 	if iter==1
# 		formula_str *= "\"$cova\""
# 	else
# 		formula_str *= " + \"$cova\""
# 	end
# 	iter=2
# end
# println(formula_str)
# formula = @formula(formula_str)

f1(x) = x
f2(x) = x^2
f3(x) = x^3
# f4(x) = exp(x)
# f5(x) = cos(x)
# f6(x) = sin(x)
# f7(x) = abs(x)
f8(x) = log(x+abs(minimum(x))+1)

funzioni = [
	f1 
	f2 
	f3 
	# f4
	# f5 
	# f6
	# f7
	f8
]

# fit = glm(formula, data, Normal(), IdentityLink())

n_tests = length(funzioni)^(length(covariate_fit)+1)
println("Doing $n_tests tests")

# aggiornare il limite qui ECC:n_tests in base a dove siete arrivati a runnare
for i in 70_000:n_tests
	X = ones(size(df)[1])
	v=digits(i,base=length(funzioni)-1,pad=length(covariate_fit)+1)
	covariate = covariate_fit
	for j in 1:(length(v)-1)
		X = [X funzioni[v[j]+1].(df[:,covariate[j]])]
	end
	y=funzioni[v[end]+1].(df[:,"Psychological well-being"])
	fit=lm(X,y)
	pval = normality(residuals(fit)).pval[1]
	i%1000 == 0 && println(i)
	# @show fit
	if(pval>1e-20)
		@show v i
		println(pval)
	end
end

# covariate = covariate_fit
# for combination in IterTools.subsets(covariate)
# 	formula = FormulaTerm(Term(Symbol("Psychological well-being")), Tuple(Term.(Symbol.(combination))))
# 	if length(combination) > 0
# 	  fit=lm(formula, df)
# 	  println(normality(residuals(fit)).pval[1])
# 	end
# 	# @show(formula)
# end