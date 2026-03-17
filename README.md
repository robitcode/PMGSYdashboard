# PMGSY Analytics Dashboard

This repository contains a high-performance, interactive **Shiny for R** application designed to visualize and analyze data from the **Pradhan Mantri Gram Sadak Yojana (PMGSY)**, India's flagship rural road connectivity programme.

## 📊 Project Overview

The dashboard provides a comprehensive geospatial and statistical analysis of rural infrastructure development across India. It tracks key performance indicators (KPIs) for road and bridge construction, sanctioned vs. completed works, and financial expenditure.

### Key Features

* **Multi-Level Analytics**: View data at a national level or drill down into specific states and districts.
* **Geospatial Visualization**: Interactive state-level maps using `tmap` to visualize metrics like road completion percentages and expenditure.
* **Performance Leaderboards**: Instantly identify the top and bottom 5 performers (States or Districts) based on expenditure and physical progress.
* **Interactive EDA**: Dynamic charts and aggregated data tables that update instantly based on user-selected filters for schemes and geographic scope.
* **Guided Tour**: Built-in interactive onboarding using `rintrojs` to help users navigate the dashboard's features.

## 🛠️ Tech Stack

* **Framework**: [Shiny](https://shiny.posit.co/)
* **UI Components**: `bslib` (Bootstrap 5), `shinycssloaders`, `DT`
* **Data Processing**: `dplyr`, `sf`
* **Visualization**: `ggplot2`, `tmap`, `rintrojs`
* **Styling**: Custom CSS integrated via `styles.R` for a modern, professional aesthetic

## 📂 File Structure

* `app.R`: The core Shiny application containing the UI definition and server logic.
* `styles.R`: Custom CSS tokens and UI styling for the "PMGSY Analytics" theme.
* `PMGSY.csv`: The primary dataset containing road and bridge metrics.
* `INDIA.shp` (and related files): Shapefiles used for geospatial mapping of Indian states.

## 🚀 Getting Started

### Prerequisites

Ensure you have **R** installed, along with the following libraries:

```r
install.packages(c("shiny", "bslib", "dplyr", "ggplot2", "sf", "tmap", "DT", "rintrojs", "shinycssloaders"))
```

### Running the App

1. Clone this repository.
2. Set your working directory to the project folder.
3. Run the following command in your R console:

```r
shiny::runApp()
```
