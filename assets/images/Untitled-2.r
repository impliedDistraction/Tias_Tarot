# Model A
print("--- Model A Response ---")
x <- c(10, 8, 12, 14, 11)
sample_variance <- var(x)
print(sample_variance)

# Model B
print("--- Model B Response ---")
x <- c(10, 12, 8, 15, 9)
sample_variance <- var(x)
print(sample_variance)

x <- c(10, 12, 8, 15, 9)
population_variance <- var(x) * (length(x)-1) / length(x)
print(population_variance)