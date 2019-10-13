
db.createUser(
    {
        user: "${MQTT_CLIENT_DB_USER}",
        pwd: "${MQTT_CLIENT_DB_PASS}",
        roles: [
            {
                role: "readWrite",
                db: "${MQTT_CLIENT_DB}"
            }
        ]
    }
);

db.createUser(
    {
        user: "${UNIT_SERVICE_DB_USER}",
        pwd: "${UNIT_SERVICE_DB_PASS}",
        roles: [
            {
                role: "readWrite",
                db: "${UNIT_SERVICE_DB}"
            }
        ]
    }
);

db.createUser(
    {
        user: "${SCHEDULER_SERVICE_DB_USER}",
        pwd: "${SCHEDULER_SERVICE_DB_PASS}",
        roles: [
            {
                role: "readWrite",
                db: "${SCHEDULER_SERVICE_DB}"
            }
        ]
    }
);

db.createUser(
    {
        user: "${REPORTING_SERVICE_DB_USER}",
        pwd: "${REPORTING_SERVICE_DB_PASS}",
        roles: [
            {
                role: "readWrite",
                db: "${REPORTING_SERVICE_DB}"
            }
        ]
    }
);

db.createUser(
    {
        user: "${API_GATEWAY_DB_USER}",
        pwd: "${API_GATEWAY_DB_PASS}",
        roles: [
            {
                role: "readWrite",
                db: "${API_GATEWAY_DB}"
            }
        ]
    }
);

db = db.getSiblingDB("${API_GATEWAY_DB}");

db.users.save(
    {
        _id: "${API_GATEWAY_SECURITY_USER_BACKEND}",
        firstName: "TECHNICAL",
        lastName: "ACCOUNT",
        password:  "${API_GATEWAY_SECURITY_PASS_BACKEND_HASH}",
        email: "none@none.com",
        active: true,
        roles: ["BACKEND"]
    }
);

db.users.save(
    {
        _id: "${API_GATEWAY_SECURITY_USER_USER}",
        firstName: "TECHNICAL",
        lastName: "ACCOUNT",
        password:  "${API_GATEWAY_SECURITY_PASS_USER_HASH}",
        email: "none@none.com",
        active: true,
        roles: ["USER"]
    }
);

db.users.save(
    {
        _id: "${API_GATEWAY_SECURITY_USER_ADMIN}",
        firstName: "TECHNICAL",
        lastName: "ACCOUNT",
        password:  "${API_GATEWAY_SECURITY_PASS_ADMIN_HASH}",
        email: "none@none.com",
        active: true,
        roles: ["ADMIN"]
    }
);