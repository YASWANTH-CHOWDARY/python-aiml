"""
Career Copilot - Streamlit app

Loads the 3 models trained in the notebook (income regression,
attrition classifier, stagnation classifier) and lets someone punch in
their own profile to see where they land.

Run with: streamlit run app.py
"""

import streamlit as st
import pandas as pd
import numpy as np
import joblib
import plotly.express as px
import plotly.graph_objects as go

st.set_page_config(page_title="Career Copilot", page_icon=":briefcase:", layout="wide")

# ----------------------------------------------------------------------
# Load models + reference data (cached so it only happens once)
# ----------------------------------------------------------------------

@st.cache_resource
def load_models():
    """Load the trained pipelines + their feature lists.

    Wrapped in try/except because this app is useless without the model
    files - if they're missing (e.g. notebook wasn't run yet, or files
    didn't get copied over), better to show one clear error message
    than crash with a confusing traceback.
    """
    try:
        income_model = joblib.load("models/income_model.joblib")
        attrition_model = joblib.load("models/attrition_model.joblib")
        stagnation_model = joblib.load("models/stagnation_model.joblib")

        income_features = joblib.load("models/income_features.joblib")
        attrition_features = joblib.load("models/attrition_features.joblib")["features"]
        stagnation_features = joblib.load("models/stagnation_features.joblib")["features"]

        return {
            "income_model": income_model,
            "attrition_model": attrition_model,
            "stagnation_model": stagnation_model,
            "income_features": income_features,
            "attrition_features": attrition_features,
            "stagnation_features": stagnation_features,
        }
    except FileNotFoundError as e:
        st.error(
            f"Couldn't find a model file ({e}). "
            "Run the notebook first so it saves the .joblib files into models/."
        )
        st.stop()


@st.cache_data
def load_reference_data():
    """The cleaned dataset, used to compare a person against the dataset
    as a whole (e.g. 'your income is in the top 20%')."""
    try:
        return pd.read_csv("data/employees_clean.csv")
    except FileNotFoundError:
        st.error("Couldn't find data/employees_clean.csv - run the notebook first.")
        st.stop()


models = load_models()
clean = load_reference_data()

DEPARTMENTS = sorted(clean["department"].unique())
JOB_ROLES = sorted(clean["job_role"].unique())
EDUCATION_FIELDS = sorted(clean["education_field"].unique())
MARITAL_STATUSES = sorted(clean["marital_status"].unique())
GENDERS = sorted(clean["gender"].unique())

# ----------------------------------------------------------------------
# Sidebar - tell us about yourself
# ----------------------------------------------------------------------

st.sidebar.header("Tell me about your job")

department = st.sidebar.selectbox("Department", DEPARTMENTS)
job_role = st.sidebar.selectbox("Job role", JOB_ROLES)
education_field = st.sidebar.selectbox("Education field", EDUCATION_FIELDS)
marital_status = st.sidebar.selectbox("Marital status", MARITAL_STATUSES)
gender = st.sidebar.selectbox("Gender", GENDERS)

age = st.sidebar.slider("Age", 18, 60, 30)
education = st.sidebar.slider("Education level (1=Below College, 5=Doctor)", 1, 5, 3)
job_level = st.sidebar.slider("Job level (1=Entry, 5=Executive)", 1, 5, 2)
total_working_years = st.sidebar.slider("Total years of work experience", 0, 40, 5)
years_at_company = st.sidebar.slider("Years at current company", 0, 40, 3)
years_in_current_role = st.sidebar.slider("Years in current role", 0, 18, 2)
years_with_curr_manager = st.sidebar.slider("Years with current manager", 0, 17, 2)
years_since_last_promotion = st.sidebar.slider("Years since last promotion", 0, 15, 1)

monthly_income = st.sidebar.number_input("Current monthly income ($)", min_value=1000, max_value=25000, value=5000, step=100)

job_satisfaction = st.sidebar.slider("Job satisfaction (1=Low, 4=Very High)", 1, 4, 3)
environment_satisfaction = st.sidebar.slider("Environment satisfaction (1=Low, 4=Very High)", 1, 4, 3)
relationship_satisfaction = st.sidebar.slider("Relationship satisfaction (1=Low, 4=Very High)", 1, 4, 3)
work_life_balance = st.sidebar.slider("Work life balance (1=Bad, 4=Best)", 1, 4, 3)

num_companies_worked = st.sidebar.slider("Number of companies worked at before this one", 0, 9, 1)
training_times_last_year = st.sidebar.slider("Trainings attended last year", 0, 6, 2)
overtime = st.sidebar.radio("Do you regularly work overtime?", ["No", "Yes"])

st.sidebar.caption("Numbers above are filled in from the dataset's actual ranges, not made up.")

# ----------------------------------------------------------------------
# Build a single-row dataframe matching what each model expects
# ----------------------------------------------------------------------

satisfaction_index = (job_satisfaction + environment_satisfaction + relationship_satisfaction + work_life_balance) / 4
is_overtime = 1 if overtime == "Yes" else 0

profile = {
    "department": department,
    "job_role": job_role,
    "education_field": education_field,
    "marital_status": marital_status,
    "gender": gender,
    "age": age,
    "education": education,
    "job_level": job_level,
    "total_working_years": total_working_years,
    "years_at_company": years_at_company,
    "years_in_current_role": years_in_current_role,
    "years_with_curr_manager": years_with_curr_manager,
    "monthly_income": monthly_income,
    "job_satisfaction": job_satisfaction,
    "environment_satisfaction": environment_satisfaction,
    "relationship_satisfaction": relationship_satisfaction,
    "work_life_balance": work_life_balance,
    "num_companies_worked": num_companies_worked,
    "training_times_last_year": training_times_last_year,
    "is_overtime": is_overtime,
    "satisfaction_index": satisfaction_index,
}
profile_df = pd.DataFrame([profile])


def predict_safe(model, features, label):
    """Run a model's predict/predict_proba, but don't let one broken
    model take down the whole page - show what we can and flag what we
    can't."""
    try:
        row = profile_df[features]
        if hasattr(model, "predict_proba"):
            return model.predict_proba(row)[0, 1], None
        else:
            return model.predict(row)[0], None
    except Exception as e:
        return None, f"{label} prediction failed: {e}"


predicted_income, income_err = predict_safe(models["income_model"], models["income_features"]["cat"] + models["income_features"]["num"], "Income")
attrition_risk, attrition_err = predict_safe(models["attrition_model"], models["attrition_features"], "Attrition")
stagnation_risk, stagnation_err = predict_safe(models["stagnation_model"], models["stagnation_features"], "Stagnation")

# ----------------------------------------------------------------------
# Main page
# ----------------------------------------------------------------------

st.title("Career Copilot")
st.write("Fill in your profile on the left, and see how it compares to the IBM HR dataset (1,470 employees) the models were trained on.")

col1, col2, col3 = st.columns(3)

with col1:
    st.subheader("Expected income")
    if income_err:
        st.warning(income_err)
    else:
        st.metric("Model estimate", f"${predicted_income:,.0f}/mo")
        diff = monthly_income - predicted_income
        if diff > 0:
            st.caption(f"You're earning ${diff:,.0f} more than the model expects for this profile.")
        else:
            st.caption(f"You're earning ${abs(diff):,.0f} less than the model expects for this profile.")

with col2:
    st.subheader("Attrition risk")
    if attrition_err:
        st.warning(attrition_err)
    else:
        st.metric("Estimated risk", f"{attrition_risk:.0%}")
        if attrition_risk > 0.5:
            st.caption("Higher than average - worth a look at what's driving it below.")
        else:
            st.caption("Lower than average.")

with col3:
    st.subheader("Stagnation risk")
    if stagnation_err:
        st.warning(stagnation_err)
    else:
        st.metric("Estimated risk", f"{stagnation_risk:.0%}")
        if stagnation_risk > 0.5:
            st.caption("Looks like you might be due for a promotion conversation.")
        else:
            st.caption("Looks fine for now.")

st.divider()

# ----------------------------------------------------------------------
# Where you stand vs. the dataset
# ----------------------------------------------------------------------

st.header("How you compare")

st.caption(
    "All three charts below are in 3D - drag with your mouse to rotate, scroll to zoom. "
    "Cufflinks isn't used here: it's an old shortcut for making Plotly charts from a "
    "dataframe in one line, but it's unmaintained and actually breaks with current "
    "numpy/Plotly versions, so this app just uses Plotly directly."
)

tab1, tab2, tab3, tab4 = st.tabs([ "Dashboard","Income", "Attrition patterns", "Stagnation patterns"])


def add_you_marker(fig, x, y, z, z_floor, color="yellow"):
    """Drops a clearly-labeled marker into a 3D scatter, plus a dotted
    line down to the floor of the plot - a single point is easy to lose
    inside a cloud of 1000+ background points otherwise, the line gives
    your eye something to follow down to the axes."""
    fig.add_trace(go.Scatter3d(
        x=[x, x], y=[y, y], z=[z_floor, z],
        mode="lines",
        line=dict(color="black", width=4, dash="dot"),
        showlegend=False,
    ))
    fig.add_trace(go.Scatter3d(
        x=[x], y=[y], z=[z],
        mode="markers+text",
        marker=dict(size=14, color=color, line=dict(color="black", width=3), symbol="diamond"),
        text=["YOU"], textposition="top center", textfont=dict(size=14, color="black"),
        name="You",
    ))


def income_3d_scatter(clean, age, total_working_years, monthly_income):
    """Age x experience x income, colored by who left."""
    fig = go.Figure()

    fig.add_trace(go.Scatter3d(
        x=clean["age"], y=clean["total_working_years"], z=clean["monthly_income"],
        mode="markers",
        marker=dict(size=3, color=clean["attrition_flag"],
                    colorscale=[[0, "#4E79A7"], [1, "#E15759"]], opacity=0.35),
        name="Dataset",
        text=clean["job_role"],
    ))
    add_you_marker(fig, age, total_working_years, monthly_income, clean["monthly_income"].min())
    fig.update_layout(
        scene=dict(xaxis_title="Age", yaxis_title="Years experience", zaxis_title="Monthly income ($)"),
        height=600,
        margin=dict(l=0, r=0, b=0, t=30),
    )
    return fig


def stagnation_3d_scatter(clean, satisfaction_index, years_at_company, years_since_last_promotion):
    """Satisfaction x tenure x promotion gap, colored by the stagnation flag."""
    fig = go.Figure()

    fig.add_trace(go.Scatter3d(
        x=clean["satisfaction_index"], y=clean["years_at_company"], z=clean["years_since_last_promotion"],
        mode="markers",
        marker=dict(size=3, color=clean["stagnation_flag"],
                    colorscale=[[0, "#59A14F"], [1, "#F28E2B"]], opacity=0.35),
        name="Dataset",
        text=clean["job_role"],
    ))
    add_you_marker(fig, satisfaction_index, years_at_company, years_since_last_promotion,
                    clean["years_since_last_promotion"].min())
    fig.update_layout(
        scene=dict(xaxis_title="Satisfaction index", yaxis_title="Years at company",
                   zaxis_title="Years since promotion"),
        height=600,
        margin=dict(l=0, r=0, b=0, t=30),
    )
    return fig


def pay_surface(clean, job_level, years_at_company, monthly_income):
    """Average income across job_level x tenure bucket, as a surface,
    with your own point floating above/below it."""
    bucketed = clean.copy()
    bucketed["tenure_bucket"] = pd.cut(
        bucketed["years_at_company"], bins=[-1, 2, 5, 10, 15, 40], labels=[1, 4, 7, 12, 20]
    ).astype(float)

    grid = bucketed.groupby(["job_level", "tenure_bucket"])["monthly_income"].mean().reset_index()
    pivot = grid.pivot(index="tenure_bucket", columns="job_level", values="monthly_income")

    fig = go.Figure()
    fig.add_trace(go.Surface(
        z=pivot.values, x=pivot.columns.values, y=pivot.index.values,
        colorscale="Viridis", opacity=0.85, showscale=True,
    ))
    add_you_marker(fig, job_level, years_at_company, monthly_income, clean["monthly_income"].min(), color="red")
    fig.update_layout(
        scene=dict(xaxis_title="Job level", yaxis_title="Years at company", zaxis_title="Avg monthly income ($)"),
        height=600,
        margin=dict(l=0, r=0, b=0, t=30),
    )
    return fig

with tab1:
    st.write("General look at the dataset as a whole - same charts as in the analysis notebook.")

    attrition_counts = clean["attrition"].value_counts()
    fig = px.pie(values=attrition_counts.values, names=attrition_counts.index, title="Who's leaving?")
    st.plotly_chart(fig, width="stretch", key="dash_pie")

    fig = px.histogram(clean, x="monthly_income", color="attrition", barmode="overlay", nbins=40,
                        title="Income, split by who left")
    st.plotly_chart(fig, width="stretch", key="dash_income_hist")

    fig = px.box(clean, x="job_role", y="monthly_income", color="attrition", title="Income by role")
    fig.update_layout(xaxis_tickangle=-30)
    st.plotly_chart(fig, width="stretch", key="dash_box")

    fig = px.violin(clean, x="over_time", y="monthly_income", box=True, title="Income by overtime status")
    st.plotly_chart(fig, width="stretch", key="dash_violin")

    overtime_dept = (
        clean.groupby(["department", "over_time"])
        .agg(n=("employee_number", "count"), attrition_rate=("attrition_flag", "mean"))
        .reset_index()
    )
    fig = px.bar(overtime_dept, x="department", y="attrition_rate", color="over_time", barmode="group",
                 title="Attrition rate by dept, split by overtime")
    st.plotly_chart(fig, width="stretch", key="dash_grouped_bar")
    st.caption("Overtime makes attrition worse in every department, not just one or two.")

    fig = px.scatter(clean, x="total_working_years", y="monthly_income", color="attrition",
                      title="Income vs experience", opacity=0.6)
    st.plotly_chart(fig, width="stretch", key="dash_scatter")

    numeric_df = clean.select_dtypes(include=[np.number])
    corr = numeric_df.corr()
    fig = px.imshow(corr, color_continuous_scale="RdBu_r", zmin=-1, zmax=1, title="Correlation heatmap")
    fig.update_layout(height=700)
    st.plotly_chart(fig, width="stretch", key="dash_heatmap")
with tab2:
    if income_err:
        st.info("Income model isn't available, skipping this chart.")
    else:
        fig = income_3d_scatter(clean, age, total_working_years, monthly_income)
        st.plotly_chart(fig, width="stretch", key="income_scatter")
        percentile = (clean["monthly_income"] < monthly_income).mean()
        st.write(f"Your stated income is higher than **{percentile:.0%}** of people in the dataset.")
        st.caption("Red dots = people who left. Your point is the black diamond.")

        st.plotly_chart(pay_surface(clean, job_level, years_at_company, monthly_income),
                         width="stretch", key="pay_surface")
        st.caption("The surface is average income by job level and tenure. Your point (red diamond) "
                   "sitting above the surface means you're paid more than the model would expect "
                   "for your level/tenure; below it means less.")

with tab3:
    same_role = clean[clean["job_role"] == job_role]
    role_attrition_rate = same_role["attrition_flag"].mean()
    st.write(f"Among **{job_role}**s in the dataset, **{role_attrition_rate:.0%}** left the company.")

    fig = income_3d_scatter(clean, age, total_working_years, monthly_income)
    st.plotly_chart(fig, width="stretch", key="attrition_scatter")
    st.caption("Same chart as the income tab, but the point to focus on here is the color: "
               "red dots are people who left. If you're sitting in a red-heavy area, that's "
               "worth noting alongside your attrition risk score above.")

with tab4:
    fig = stagnation_3d_scatter(clean, satisfaction_index, years_at_company, years_since_last_promotion)
    st.plotly_chart(fig, width="stretch", key="stagnation_scatter")

    pct_below = (clean["years_since_last_promotion"] < years_since_last_promotion).mean()
    st.write(f"**{pct_below:.0%}** of people in the dataset have gone *less* time than you without a promotion.")
    st.caption("Orange dots = flagged as 'stagnating' (longer than median since their last promotion).")



st.divider()
st.caption("Built on the IBM HR Analytics Employee Attrition dataset. Models: Linear Regression (income), "
           "Logistic Regression (attrition), Random Forest (stagnation).")
