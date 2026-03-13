library(ggplot2)
library(sf)
library(sysfonts)
library(showtext)
library(geomtextpath)

# Register Figtree font from epitemplate
font_add(
  "Figtree",
  regular = "/tmp/epitemplate/inst/pkgdown/assets/fonts/Figtree-VariableFont_wght.woff2"
)
showtext_auto()

# --- Geological strata pattern ---
set.seed(123)
n_layers <- 24
n_points <- 500

x <- seq(-1.5, 1.5, length.out = n_points)

# Build smooth layer boundaries — start well below hex bottom
layers_list <- list()
base <- rep(-2.0, n_points)

for (i in seq_len(n_layers)) {
  thickness <- runif(1, 0.12, 0.22)
  # Low frequencies only for smooth, gentle geological undulation
  wave <- runif(1, 0.04, 0.10) *
    sin(runif(1, 0.3, 0.8) * x * pi + runif(1, 0, 2 * pi)) +
    runif(1, 0.02, 0.04) *
      sin(runif(1, 0.6, 1.2) * x * pi + runif(1, 0, 2 * pi))
  top <- base + thickness + wave
  layers_list[[i]] <- list(base = base, top = top)
  base <- top
}

# Palette: slate grays alternating with amber/orange/tan
geo_palette <- c(
  "#3B3B3B",
  "#7A7A7A",
  "#D4A04A",
  "#5A5A5A",
  "#C17E2F",
  "#909090",
  "#E8B44C",
  "#4A4A4A",
  "#D4A574",
  "#6B6B6B",
  "#E0943A",
  "#B0A898",
  "#555555",
  "#C8A060",
  "#8C8C8C",
  "#D98C28",
  "#6E6E6E",
  "#E8C878",
  "#3B3B3B",
  "#7A7A7A",
  "#D4A04A",
  "#5A5A5A",
  "#C17E2F",
  "#909090"
)

# Standard hex sticker: regular pointy-top hexagon
# All vertices at equal radius from center
angles <- seq(pi / 2, 2 * pi + pi / 2, length.out = 7)
hex_x <- cos(angles)
hex_y <- sin(angles)
# Ensure exact closure
hex_x[7] <- hex_x[1]
hex_y[7] <- hex_y[1]
hex_sf <- st_polygon(list(cbind(hex_x, hex_y)))

# Clip each layer to the hex using sf
clipped_layers <- data.frame()
for (i in seq_len(n_layers)) {
  b <- layers_list[[i]]$base
  t <- layers_list[[i]]$top
  # Create closed polygon: top edge left-to-right, base edge right-to-left
  poly_x <- c(x, rev(x), x[1])
  poly_y <- c(t, rev(b), t[1])
  layer_sf <- tryCatch(
    st_polygon(list(cbind(poly_x, poly_y))),
    error = function(e) NULL
  )
  if (is.null(layer_sf)) {
    next
  }

  clipped <- tryCatch(
    {
      layer_sfc <- st_sfc(layer_sf)
      hex_sfc <- st_sfc(hex_sf)
      result <- st_intersection(layer_sfc, hex_sfc)
      if (length(result) > 0 && !st_is_empty(result)) result[[1]] else NULL
    },
    error = function(e) NULL
  )

  if (!is.null(clipped)) {
    coords <- st_coordinates(clipped)
    clipped_layers <- rbind(
      clipped_layers,
      data.frame(x = coords[, 1], y = coords[, 2], layer = i)
    )
  }
}

# Pick a layer near the vertical center for the text
mid_layer <- which.min(sapply(seq_len(n_layers), function(i) {
  mid <- (layers_list[[i]]$base + layers_list[[i]]$top) / 2
  in_hex <- x >= -0.7 & x <= 0.7
  mean(abs(mid[in_hex])) + sd(mid[in_hex])
}))

# Merge mid_layer with the layer above it (mid_layer + 1) into one thick dark band
# Extend mid_layer's top to use the next layer's top
merge_with <- mid_layer + 1
layers_list[[mid_layer]]$top <- layers_list[[merge_with]]$top
geo_palette[mid_layer] <- "#3B3B3B"

# Remove the merged layer from clipped data and reclip the merged layer
clipped_layers <- clipped_layers[clipped_layers$layer != merge_with, ]
# Reclip the merged layer
b_merge <- layers_list[[mid_layer]]$base
t_merge <- layers_list[[mid_layer]]$top
poly_x_m <- c(x, rev(x), x[1])
poly_y_m <- c(t_merge, rev(b_merge), t_merge[1])
layer_sf_m <- st_polygon(list(cbind(poly_x_m, poly_y_m)))
clipped_m <- st_intersection(st_sfc(layer_sf_m), st_sfc(hex_sf))
if (length(clipped_m) > 0 && !st_is_empty(clipped_m)) {
  coords_m <- st_coordinates(clipped_m[[1]])
  clipped_layers <- clipped_layers[clipped_layers$layer != mid_layer, ]
  clipped_layers <- rbind(
    clipped_layers,
    data.frame(x = coords_m[, 1], y = coords_m[, 2], layer = mid_layer)
  )
}

# Build the midline path for the merged layer and compute angle at center
mid_y <- (layers_list[[mid_layer]]$base + layers_list[[mid_layer]]$top) / 2
# Center point of the text
center_idx <- which.min(abs(x))
text_center_x <- x[center_idx]
text_center_y <- mid_y[center_idx]
# Slope at center (using nearby points)
dx <- x[center_idx + 5] - x[center_idx - 5]
dy <- mid_y[center_idx + 5] - mid_y[center_idx - 5]
text_angle <- atan2(dy, dx) * 180 / pi

p <- ggplot() +
  # Fill hex background with darkest color
  geom_polygon(
    data = data.frame(x = hex_x[1:6], y = hex_y[1:6]),
    aes(x = x, y = y),
    fill = "#2E2E2E",
    color = NA
  ) +
  # Strata layers
  geom_polygon(
    data = clipped_layers,
    aes(x = x, y = y, fill = factor(layer), group = layer),
    color = NA
  ) +
  scale_fill_manual(values = setNames(geo_palette, seq_len(n_layers))) +
  # Text angled to follow the stratum at center
  annotate(
    "text",
    x = text_center_x + 0.03,
    y = text_center_y + 0.03,
    label = "epiextractr",
    angle = text_angle - 8 / pi,
    color = "white",
    size = 30,
    fontface = "bold",
    family = "Figtree"
  ) +
  coord_fixed() +
  theme_void() +
  theme(
    legend.position = "none",
    plot.background = element_rect(fill = "white", color = NA)
  )

# Match epitargets logo dimensions: 1037 x 1200 pixels
ggsave(
  "man/figures/logo.png",
  p,
  width = 1037 / 300,
  height = 1200 / 300,
  dpi = 300,
  bg = "white"
)

message("Sticker saved to man/figures/logo.png")
