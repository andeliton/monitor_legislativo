# ==============================================================================
# ARS METRICA - SCRIPT DE CONFIGURAÇÃO DO AMBIENTE
# ==============================================================================

# 1. Lista de pacotes necessários para o App
pacotes_necessarios <- c(
  "shiny",
  "bslib",
  "tidyverse",
  "arrow",
  "DT",
  "bsicons",
  "waiter",
  "scales",   # Usado para formatar porcentagens
  "viridris"  # Usado nas cores do gráfico (opcional, já vem no ggplot mas bom garantir)
)

# 2. Função para verificar e instalar
instalar_se_faltar <- function(pct) {
  if (!require(pct, character.only = TRUE)) {
    message(paste("Instalando pacote:", pct))
    install.packages(pct)
  } else {
    message(paste("Pacote já instalado:", pct))
  }
}

# 3. Executa a verificação
lapply(pacotes_necessarios, instalar_se_faltar)

message("\n--- CONFIGURAÇÃO CONCLUÍDA ---")
message("Abra o arquivo 'app.R' e clique em 'Run App'.")