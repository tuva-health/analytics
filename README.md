# Tuva Analytics Library

This repository is a home for community-built, open-source **Streamlit apps** that enhance and extend the utility of the Tuva data model. These tools are built by Tuva Project staff and community members to provide insights, analyses, and dashboards on top of Tuva's healthcare claims data, including synthetic and real-world datasets.

Apps can be contributed by anyone and are organized within this repo for easy discovery, reuse, and ongoing development.

---

## 📁 Folder Structure

```
analytics/
├── shared/                  # Shared Python modules (helpers, config, plotting, etc.)
│   ├── utils/
│   │   └── helpers.py       # Common data loading or transformation logic
│   └── path_utils.py        # Adds the repo root to sys.path for clean imports
│
├── streamlit_apps/         # All Streamlit apps live here
│   └── tuva_template/       # Example app with Snowflake connection and multipage layout
│       ├── app.py
│       ├── pages/
│       │   ├── dashboard.py
│       │   └── claim_amount.py
│       ├── .streamlit/      # Config and secrets
│       │   └── config.toml
│       └── requirements.txt
│
├── .venv/ (optional)        # Virtual environment (not checked into version control)
└── README.md                # You're here
```

---

## 🆕 Setting Up a New Streamlit App

To create a new app:

1. Create a new folder inside `streamlit_apps/`, e.g. `streamlit_apps/my_new_app/`
2. Inside that folder, add:
   - `app.py` — your main Streamlit entry point
   - `requirements.txt` — app-specific dependencies (optional if shared)
   - `.streamlit/` folder with `config.toml` and `secrets.toml`
   - (optional) `pages/` subfolder for multipage apps
3. Use shared code from `shared/utils/` (e.g. `helpers.get_table_data()`)
4. Follow the setup instructions below to install and run it locally

---

## ⚙️ Setup & Installation

### 1. Prerequisites
- Python (>=3.8, <3.13)
- pip (Python package installer)
- Git
- Access to a Snowflake account (if needed for the app)

### 2. Clone the Repository

```bash
git clone https://github.com/tuva-health/analytics.git
cd analytics
```

### 3. Create a Virtual Environment & Install Dependencies

#### 💻 macOS/Linux
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install --upgrade pip
pip install -r streamlit_apps/tuva_template/requirements.txt
```

#### 🪟 Windows
```bash
python -m venv .venv
.venv\Scripts\activate
pip install --upgrade pip
pip install -r streamlit_apps/tuva_template/requirements.txt
```

---

## 🔐 Configure Snowflake Credentials

Create the following file inside your app folder (e.g. `streamlit_apps/tuva_template/.streamlit/secrets.toml`):

```toml
[snowflake]
user = "your_username"
account = "your_account"
warehouse = "your_warehouse"
database = "your_database"
schema = "your_schema"
authenticator = "externalbrowser"
```

> ✅ This file is ignored by Git via `.gitignore`. Do not commit it.

---

## ▶️ Running a Streamlit App

To run an app (e.g. `tuva_template`), from the root of that app:

```bash
cd streamlit_apps/tuva_template
streamlit run app.py
```

This will launch the app in your browser at [http://localhost:8501](http://localhost:8501)

If you're using `externalbrowser` as the authenticator, it will open a tab for login. Make sure you're already logged into Snowflake in the browser that opens.

---

## 💡 Usage
- Use dashboards to explore claim types, trends, or cost breakdowns
- Filter and visualize data retrieved directly from Snowflake
- Extend any app or build your own using shared helper functions and plotting utilities

---

## 🛠️ Troubleshooting

- If dependencies fail to install:
  ```bash
  pip install --upgrade pip
  ```
- If you get `ModuleNotFoundError: shared`, ensure your import block in pages uses this:
  ```python
  import sys
  from pathlib import Path
  sys.path.append(str(Path(__file__).resolve().parents[3]))

  from shared import path_utils
  path_utils.add_repo_to_path(levels_up=3)
  ```
- If authentication fails, double-check your `.streamlit/secrets.toml`
- If Snowflake access errors appear, verify you have the necessary permissions in your role

---

## 📄 License

Copyright © 2025 The Tuva Project.

