using Chain, Random, Distributions, Statistics, StatsBase, GLMakie, InvertedIndices

#1: get population 
#2: get multiple samples
#3: plot distributions of means
#4: colorize +/- 1.96 (95%) aller Mittelwerte
#5: do calculations


# ---------------------
# Figure
fontsize_theme = Theme(fontsize = 10)
set_theme!(fontsize_theme)
fig = Figure(resolution = (2000,2000))
display(fig)
#
# Observables
μ = Observable(250)
σ = Observable(15)
n = Observable(1)
#
# Sliders
sg = SliderGrid(fig[2,2],
                (label = "Mean μ", range = 225:275, startvalue = 250),
                (label = "Variance σ", range = 1:50, startvalue = 15),
                (label = "Number of Sample Means", range = 2:1:3000, startvalue = 3)
               )
#
connect!(μ, sg.sliders[1].value)
connect!(σ, sg.sliders[2].value)
connect!(n, sg.sliders[3].value)
#
# Population Plot
pop = @lift(rand(Normal($μ, $σ), 100000))
#
ax_pop = Axis(fig[1:2, 1],
              title = "Population",
              ylabel = "Merkmal",
              xlabel = "")
scatter!(pop, markersize = 1)
#
# Population Formula
ax_pop_tex = Axis(fig[1,2])
xlims!(0, 1)
ylims!(2, -2)
hidespines!(ax_pop_tex);
hidedecorations!(ax_pop_tex);
pop_text = @lift("Merkmal ~ Normal($($μ), $($σ))")
text!(0, 0, 
      text = pop_text,
     fontsize = 40)
#
# One Sample
indices = rand(1:100000, 25)
in_sample = @lift($pop[indices])
sample_mean = @lift(mean($in_sample))
#out_sample = @lift($pop[Not(indices)])
ax_one_sample = Axis(fig[3, 1],
                     title = "One Sample",
                     ylabel = "Merkmal",
                     xlabel = "")
#scatter!(out_sample, markersize = 10, color = :grey)
scatter!(in_sample, markersize = 40, color = :red)
hlines!(sample_mean, color = :red)
text!(22, sample_mean, text = "Mean", fontsize = 40, color = :red)
#scatter!(pop[][indices], markersize = 10, color = :red)
#in_sample = @lift()
#
# Sample Formula
ax_sample_tex = Axis(fig[3,2])
xlims!(0, 1)
ylims!(2, -2)
hidespines!(ax_sample_tex);
hidedecorations!(ax_sample_tex);
text!(0.05, -0.5, text = L"\bar{x}=\frac{1}{n} \sum x_m", fontsize = 50)
sample_mean_text = @lift("    = $(round(mean($in_sample), digits = 2))")
sample_sd_text = @lift("    = $(round(std($in_sample), digits = 2))")
text!(.295, -0.7, text = sample_mean_text, fontsize = 40)
 
text!(0.05, 1.25, text = L"s_{x} =\sqrt{ \frac{\sum\left(x_m-\bar{x}\right)^2}{n} }", fontsize = 40)
text!(.4, 1.05, text = sample_sd_text, fontsize = 40)
#text!(0.05, 1.5, text = L"s_{x} = 1234", fontsize = 40)
#
# Sample Means
function get_means(p, n)
  M = []
  for i in 1:n
    stichprobe = rand(p, 25)
    m = mean(stichprobe)
    push!(M, m)
  end
  return M
end
means = @lift(get_means($pop, $n))
means_sd =  @lift(round(std(get_means($pop, $n)), digits = 2))
#
ax_means = Axis(fig[4,1],
                title = "Sample Means",
                ylabel = "",
                xlabel = "Merkmal")
hist!(means)
on(sg.sliders[3].value) do val
  autolimits!(ax_means)
end
#
# Sample Means Formula
ax_means_tex = Axis(fig[4,2])
xlims!(0, 1)
ylims!(2, -2)
hidespines!(ax_means_tex);
hidedecorations!(ax_means_tex);
#sample_sd_text = @lift("    = $(round($σ / sqrt(25)), digits = 2)")
sem_text = @lift("    = $($σ/sqrt(25))")
means_sd_text = @lift("sₓ = $($means_sd)")
text!(0.05, 1.7, text = means_sd_text, fontsize = 40)
text!(.2, 0.7, text = sem_text, fontsize = 40)
text!(0.05, 1, text = latexstring("\$ \\sigma_{\\bar{x}}=\\frac{\\sigma}{\\sqrt{n}}\$"), fontsize = 40)









mean(M)

std(M, corrected = false)

# sem = σ/sqrt(n) == std(M, corrected = false)


sem(stichprobe, mean = mean(stichprobe))

