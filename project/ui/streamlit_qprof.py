import streamlit as st
import streamlit.components.v1 as components
import tempfile
import logging
import verticapy as vp
from verticapy.performance.vertica import QueryProfilerInterface, QueryProfiler

# -----------------------------------------------
# Helper Functions
# -----------------------------------------------

def get_connection_info():
    """Retrieve and format current connection info."""
    try:
        vdf_test_sandbox = vp.vDataFrame(
            "SELECT DISTINCT sandbox FROM nodes WHERE node_state='UP' AND sandbox IS NOT NULL;"
        )
        if vdf_test_sandbox[0] is None or vdf_test_sandbox[0][0] == "":
            info = f"**Database**: {vp.current_connection().options['database']}  \n**Username**: {vp.current_connection().options['user']}"
        else:
            info = (f"**Database**: {vp.current_connection().options['database']}  \n"
                    f"**Username**: {vp.current_connection().options['user']}  \n"
                    f"**Sandbox**: {vdf_test_sandbox[0][0]}")
        return info
    except Exception:
        return "⚠️ **WARNING**: No database connection found. Please connect with a database to use this tool."

def schema_exists(schema_name):
    """Check if a given schema exists."""
    query = f"SELECT schema_name FROM v_catalog.schemata WHERE schema_name = '{schema_name}';"
    vdf = vp.vDataFrame(query)
    return vdf.shape()[0] > 0

def check_if_schema_key_exist(schema, key):
    """Placeholder for checking if the schema-key combination exists."""
    # Implement your logic here
    return False

def get_tree_html(qprof):
    """Return the HTML for the query plan tree as a string."""
    tree = qprof.get_qplan_tree(return_tree_obj=True)
    html_obj = tree.to_html()
    if hasattr(html_obj, "data"):
        html_str = html_obj.data
    elif hasattr(html_obj, "_repr_html_"):
        html_str = html_obj._repr_html_()
    else:
        html_str = str(html_obj)
    return html_str

# -----------------------------------------------
# Session State Initialization
# -----------------------------------------------
if 'show_tree' not in st.session_state:
    st.session_state.show_tree = False
if 'output_html' not in st.session_state:
    st.session_state.output_html = ""

# -----------------------------------------------
# Page Layout
# -----------------------------------------------
if st.session_state['show_tree']:
    # "New page" showing only the tree output and a "Go back" button.
    st.header("Query Plan Tree")
    components.html(st.session_state['output_html'], 
                    height=1000, 
                    width=1000,
                    scrolling=True
                    )
    if st.button("Go back"):
        st.session_state['show_tree'] = False
        st.rerun()
else:
    st.sidebar.header("Current Connection Info")
    conn_info = get_connection_info()
    st.sidebar.markdown(conn_info)

    st.title("Query Profiler Dashboard")

    # Create Tabs for two loading options
    tab1, tab2 = st.tabs(["Load from Schema & Key", "Load from File"])

    # -----------------------------------------------
    # Tab 1: Load from Schema & Key
    # -----------------------------------------------
    with tab1:
        st.header("Load Query Profiler (From DB)")
        # Query for available schemas (adjust the query as needed)
        query_schema = "SELECT DISTINCT table_schema FROM tables WHERE table_name LIKE '%_dc_explain_plans_%' ORDER BY 1;"
        vdf_schema = vp.vDataFrame(query_schema)
        schema_options = [i[0] for i in vdf_schema.to_list()]
        
        selected_schema = st.selectbox("Select Target Schema", options=schema_options)
        
        # Update key dropdown based on the selected schema.
        length_to_remove = len("qprof_dc_explain_plans_") + 1
        query_key = (
            f"SELECT SUBSTR(table_name, {length_to_remove}) AS table_name "
            f"FROM (SELECT DISTINCT table_name FROM tables "
            f"WHERE table_name LIKE '%_dc_explain_plans_%' AND table_schema = '{selected_schema}') as foo "
            "ORDER BY 1;"
        )
        vdf_key = vp.vDataFrame(query_key)
        key_options = [i[0] for i in vdf_key.to_list()]
        
        selected_key = st.selectbox("Select Key", options=key_options)
        
        if st.button("Load Query Plan"):
            if not schema_exists(selected_schema):
                st.error("Error! The schema does not exist.")
            else:
                logging.info(f"Creating QueryProfiler object using target_schema: {selected_schema}, key_id: {selected_key}.")
                # Instantiate the QueryProfiler object
                qprof = QueryProfiler(
                    target_schema=selected_schema,
                    key_id=selected_key,
                    check_tables=False,
                )
                html_output = get_tree_html(qprof)
                st.session_state['output_html'] = html_output
                st.session_state['show_tree'] = True
                st.rerun()

    # -----------------------------------------------
    # Tab 2: Load from File
    # -----------------------------------------------
    with tab2:
        st.header("Load Query Profiler (From File)")
        target_schema_input = st.text_input("Enter Target Schema")
        key_input = st.text_input("Enter Key (Optional)")
        uploaded_file = st.file_uploader("Upload Query Profiler File", type=["json", "txt", "profile"])
        
        if st.button("Load Query Plan (File)"):
            if not target_schema_input or not uploaded_file:
                st.error("Error! You must provide a value for Schema and upload a file.")
            elif check_if_schema_key_exist(target_schema_input, key_input):
                st.error("Error! The combination of schema and key already exists. Please try again with a unique key.")
            else:
                key_val = key_input if key_input else None
                logging.info(f"Creating QueryProfiler object using target_schema: {target_schema_input}, key_id: {key_val}, file: {uploaded_file.name}.")
                # Save the uploaded file to a temporary file
                with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
                    tmp_file.write(uploaded_file.read())
                    tmp_filename = tmp_file.name
                
                # Import the profile from the file using the QueryProfiler object.
                qprof = QueryProfiler.import_profile(
                    target_schema=target_schema_input,
                    key_id=key_val,
                    filename=tmp_filename,
                    auto_initialize=False
                )
                html_output = get_tree_html(qprof)
                st.session_state['output_html'] = html_output
                st.session_state['show_tree'] = True
                st.rerun()
