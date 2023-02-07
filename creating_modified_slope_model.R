### creating a slope-only model for comparison with
### a similar eBird model


library(bbsBayes2)
library(tidyverse)


model = "slope"
stratification = "latlong"
model_variant = "spatial"
firstYear = 2007
lastYear = 2018


# # copy bbsBayes2 model file to directory
# # only done once, not necessary to repeat
# copy_model_file(model = model,
#                 model_variant = model_variant,
#                 dir = "models")

### The above exported Stan file was modified manually
### to remove or quote-out all uses of the yeareffects parameters
### the resulting file was stored as the slope_only version referenced
### in the next line.
alternate_model_file <- "models/slope_only_spatial_bbs_CV.stan"

species = "Red-eyed Vireo"


s <- stratify(by = stratification,
              species = species)


p <- prepare_data(s,
                  min_n_routes = 1,
                  min_max_route_years = 3,
                  min_year = firstYear,
                  max_year = lastYear)

ps <- prepare_spatial(p,
                      strata_map = load_map(stratification),
                      label_size = 1)

print(ps$spatial_data$map)

pm <- prepare_model(ps,
                    model = model,
                    model_variant = model_variant,
                    model_file = alternate_model_file)

fit <- run_model(pm,
                 refresh = 200,
                 max_treedepth = 10, #initial try with defaults
                 adapt_delta = 0.8,#initial try with defaults
                 output_dir = "output",
                 output_basename = paste(species,stratification,model,model_variant,sep = "_"))



summ <- get_summary(fit)











