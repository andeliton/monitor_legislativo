# Monitor Legislativo (Legislative Monitor)

![R](https://img.shields.io/badge/R-4.4%2B-blue)
![Shiny](https://img.shields.io/badge/Shiny-1.8-blue)

<div align="center">
  <a href="#-english"> English</a> |
  <a href="#-português">🇧🇷 Português</a>
</div>

---

<div id="-english"></div>

## English

### About the Project
This repository contains a dashboard built with **R** and **Shiny** to visualize voting data from the Brazilian Chamber of Deputies. The application allows users to filter votes by year, party, and state, providing a clear view of parliamentary behavior.

> **Note:** The application interface is in Portuguese, as the source data is from the Brazilian legislative system.

### Features
* **Government Support Rate:** Calculates the alignment percentage of MPs with the government's official orientation.
* **Vote Tracking:** A searchable table displaying individual votes for every bill.
* **Thematic Overview:** Visualizes the volume of different types of legislative proposals (PECs, PLs, MPs).
* **Data Export:** Allows users to download filtered data (CSV) and charts (PNG).

### Technologies
* **R / Shiny:** Main framework for the web application.
* **bslib:** Used for the user interface (based on Bootstrap 5).
* **Arrow (Parquet):** Used for efficient reading of historical datasets.
* **Tidyverse:** Used for data manipulation.

### How to Run
1.  Clone this repository.
2.  Open the project in RStudio.
3.  Run the setup script to install dependencies:
    ```r
    source("setup.R")
    ```
4.  Open `app.R` and click **Run App**.

---

<div id="-português"></div>

## 🇧🇷 Português

### Sobre o Projeto
Este repositório contém um dashboard desenvolvido em **R** e **Shiny** para visualizar dados de votações nominais da Câmara dos Deputados. A aplicação permite filtrar votações por ano, partido e estado, oferecendo uma visão clara do comportamento parlamentar.

### Funcionalidades
* **Taxa de Governismo:** Calcula o percentual de alinhamento dos deputados com a orientação oficial do Governo.
* **Rastreamento de Votos:** Tabela pesquisável mostrando o voto individual em cada matéria.
* **Visão Temática:** Visualiza o volume de diferentes tipos de proposições (PECs, PLs, MPs).
* **Exportação de Dados:** Permite baixar os dados filtrados (CSV) e os gráficos gerados (PNG).

### Tecnologias
* **R / Shiny:** Framework principal da aplicação web.
* **bslib:** Utilizado para a interface de usuário (baseado em Bootstrap 5).
* **Arrow (Parquet):** Utilizado para leitura eficiente das bases de dados históricas.
* **Tidyverse:** Utilizado para manipulação de dados.

### Como Executar
1.  Clone este repositório.
2.  Abra o projeto no RStudio.
3.  Rode o script de configuração para instalar as dependências:
    ```r
    source("setup.R")
    ```
4.  Abra o arquivo `app.R` e clique em **Run App**.

---
*Developed by Andeliton Soares*
