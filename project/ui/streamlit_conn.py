import streamlit as st
import verticapy as vp
import ssl

# Page configuration
st.set_page_config(
    page_title="Vertica Connection Manager",
    page_icon="🔌",
    layout="centered"
)



# Header
st.title("Vertica Connection Manager")

# Navigation buttons
col1, col2, col3 = st.columns([1, 2, 4])
with col1:
    if st.button("🏠 Home"):
        st.switch_page("/lab/")  # Using Streamlit's navigation
with col2:
    if st.button("📊 Query Profiler"):
        st.switch_page("/voila/render/ui/qprof_main.ipynb")


# Connection form
with st.form("connection_form"):
    st.subheader("New Connection")
    
    col1, col2 = st.columns(2)
    with col1:
        host = st.text_input("Host", "verticadb")
        port = st.text_input("Port", "5433")
        user = st.text_input("User Name", "dbadmin")
    
    with col2:
        password = st.text_input("Password", type="password")
        database = st.text_input("Database", "")
        name = st.text_input("Connection Name", "VerticaDSN")
    
    # Additional settings
    with st.expander("Connection Settings"):
        connection_timeout = st.text_input("Connection Timeout (seconds)", "15")
        autocommit = st.checkbox("Autocommit")
    
    # Advanced options
    with st.expander("Advanced Options"):
        advanced_option = st.selectbox("Authentication Method", ["Basic", "OAuth", "TLS", "Kerberos"])
        
        if advanced_option == "OAuth":
            oauth_access_token = st.text_input("OAuth Access Token", type="password")
            oauth_refresh_token = st.text_input("OAuth Refresh Token", type="password")
        elif advanced_option == "Kerberos":
            kerberos_host_name = st.text_input("Kerberos Host Name")
            kerberos_service_name = st.text_input("Kerberos Service Name")
        elif advanced_option == "TLS":
            ssl_option = st.radio("TLS Verification Mode", ["Require", "Verify-CA", "Verify-Full"])
            if ssl_option in ["Verify-CA", "Verify-Full"]:
                cert_file = st.file_uploader("Upload CA Certificate")
    
    # Submit button
    submit_button = st.form_submit_button("Create Connection")

# Handle form submission
if submit_button:
    with st.spinner("Connecting to database..."):
        try:
            ssl_context = None
            if advanced_option == "TLS":
                ssl_context = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
                ssl_context.check_hostname = ssl_option == "Verify-Full"
                ssl_context.verify_mode = ssl.CERT_NONE if ssl_option == "Require" else ssl.CERT_OPTIONAL
            
            conn_info = {
                'host': host,
                'port': int(port),
                'user': user,
                'password': password,
                'ssl': ssl_context if advanced_option == "TLS" else False,
                'connection_timeout': int(connection_timeout),
            }
            
            if database:
                conn_info['database'] = database
            
            vp.new_connection(conn_info, name=name, auto=True, overwrite=True)
            st.success(f"✅ Successfully connected to {database or 'database'} as {user}")
        except Exception as e:
            st.error(f"❌ Connection failed: {e}")

st.markdown("<hr>", unsafe_allow_html=True)

# Existing connections section
st.subheader("Existing Connections")

available_connections = vp.available_connections()
if available_connections:
    selected_connection = st.selectbox(
        "Select a connection",
        available_connections
    )
    
    if st.button("Reconnect", key="reconnect_button"):
        with st.spinner("Reconnecting..."):
            try:
                vp.connect(selected_connection)
                st.success(f"✅ Successfully reconnected to: {vp.current_connection().options['database']}")
            except Exception as e:
                st.error(f"❌ Reconnection failed: {e}")
else:
    st.info("No saved connections available")

# Current connection status
try:
    current_conn = vp.current_connection()
    with st.expander("Current Connection Details"):
        st.markdown(f"""
        <div class="connection-card">
            <p><strong>Name:</strong> {current_conn.name}</p>
            <p><strong>Host:</strong> {current_conn.options.get('host', 'N/A')}</p>
            <p><strong>Database:</strong> {current_conn.options.get('database', 'N/A')}</p>
            <p><strong>User:</strong> {current_conn.options.get('user', 'N/A')}</p>
            <p><strong>Status:</strong> Active</p>
        </div>
        """, unsafe_allow_html=True)
except:
    st.warning("No active connection")