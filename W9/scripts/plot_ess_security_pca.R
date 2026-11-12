# Generate the W9 ESS appendix plot from the same unit vectors as the R05 PCA check.
# Run Rscript W9/scripts/plot_ess_security_pca.R from the course root.
# Projection examples: Schoonvelde, ESS QTA Day 3 p. 19; Liao and Müller, UCD QTA Week 11 Lab.
w9_root <- if (dir.exists("W9/classroom")) "W9" else "."
vectors <- readRDS(file.path(w9_root, "classroom/Data/w9_glove.rds"))$vectors
word_unit <- vectors / sqrt(rowSums(vectors ^ 2))
target <- "security"

cosine <- drop(word_unit %*% word_unit[target, ])
names(cosine) <- rownames(word_unit)
cosine[target] <- NA_real_
full_neighbours <- head(sort(cosine, decreasing = TRUE), 5)

pca <- prcomp(word_unit, center = TRUE, scale. = FALSE, rank. = 2)
scores <- pca$x
origin <- scores[target, ]
map_distance <- sqrt(rowSums(sweep(scores, 2, origin) ^ 2))
map_distance[target] <- NA_real_
map_neighbours <- head(sort(map_distance), 5)
variance_share <- sum(pca$sdev[1:2] ^ 2) / sum(pca$sdev ^ 2)

full_first <- names(full_neighbours)[1]
map_first <- names(map_neighbours)[1]
highlight <- c(target, full_first, map_first)
colours <- c("#314f4f", "#ba2030", "#0271bb")
x_limits <- origin[1] + c(-0.11, 0.11)
y_limits <- origin[2] + c(-0.085, 0.075)

png(file.path(w9_root, "assets/methods/ess-security-pca.png"),
    width = 1160, height = 760, res = 160, pointsize = 16, bg = "white")
par(mar = c(3.6, 5.0, 0.55, 1.35), mgp = c(2.05, 0.55, 0), tcl = -0.25,
    las = 1, family = "sans", col.axis = "#5f6f7f", col.lab = "#314f4f")
plot(scores, type = "n", xlim = x_limits, ylim = y_limits,
     xlab = "PC1", ylab = "", axes = FALSE, asp = 1)
abline(v = axTicks(1), h = axTicks(2), col = "#e3ebe7")
axis(1, col = "#8fa39a")
axis(2, col = "#8fa39a")
box(col = "#8fa39a")
mtext("PC2", side = 2, line = 3.45, las = 0, col = "#314f4f")
points(scores, pch = 16, cex = 0.45, col = "#c8d6cf")
segments(origin[1], origin[2], scores[highlight[-1], 1], scores[highlight[-1], 2],
         col = colours[-1], lwd = 1.7)
points(scores[highlight, , drop = FALSE], pch = 19, col = colours, cex = 1.1)
text(scores[highlight, , drop = FALSE], labels = highlight,
     pos = c(4, 1, 2), col = colours, cex = 1.07, font = 2)
invisible(dev.off())

print(data.frame(
  full_cosine = names(full_neighbours), cosine = unname(full_neighbours),
  pca_neighbour = names(map_neighbours), map_distance = unname(map_neighbours),
  row.names = NULL
))
cat(sprintf("Variance retained by PC1 and PC2: %.2f%%\n", 100 * variance_share))
cat("Shared top-five neighbours:", length(intersect(names(full_neighbours), names(map_neighbours))), "\n")
