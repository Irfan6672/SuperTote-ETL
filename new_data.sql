
CREATE TABLE dim_date (
    date_id date PRIMARY KEY,
    year int NOT NULL,
    month int NOT NULL,
    day int NOT NULL,
    day_of_week int NOT NULL,
    day_name varchar NOT NULL,
    month_name varchar NOT NULL,
    quarter int NOT NULL
);
CREATE TABLE dim_staff (
    staff_id int PRIMARY KEY,
    first_name varchar NOT NULL,
    last_name varchar NOT NULL,
    department_name varchar NOT NULL,
    location varchar NOT NULL,
    email_address varchar NOT NULL
);
CREATE TABLE dim_location (
    location_id int PRIMARY KEY,
    address_line_1 varchar NOT NULL,
    address_line_2 varchar,
    district varchar,
    city varchar NOT NULL,
    postal_code varchar NOT NULL,
    country varchar NOT NULL,
    phone varchar NOT NULL
);
CREATE TABLE dim_currency (
    currency_id int PRIMARY KEY,
    currency_code varchar NOT NULL,
    currency_name varchar NOT NULL
);
CREATE TABLE dim_design (
    design_id int PRIMARY KEY,
    design_name varchar NOT NULL,
    file_location varchar NOT NULL,
    file_name varchar NOT NULL
);
CREATE TABLE dim_counterparty (
    counterparty_id int PRIMARY KEY,
    counterparty_legal_name varchar NOT NULL,
    counterparty_legal_address_line_1 varchar NOT NULL,
    counterparty_legal_address_line_2 varchar,
    counterparty_legal_district varchar,
    counterparty_legal_city varchar NOT NULL,
    counterparty_legal_postal_code varchar NOT NULL,
    counterparty_legal_country varchar NOT NULL,
    counterparty_legal_phone_number varchar NOT NULL
);
CREATE TABLE fact_sales_order (
    sales_record_id SERIAL PRIMARY KEY,
    sales_order_id int NOT NULL,
    created_date date NOT NULL,
    created_time time NOT NULL,
    last_updated_date date NOT NULL,
    last_updated_time time NOT NULL,
    sales_staff_id int NOT NULL,
    counterparty_id int NOT NULL,
    units_sold int NOT NULL,
    unit_price numeric(10, 2) NOT NULL,
    currency_id int NOT NULL,
    design_id int NOT NULL,
    agreed_payment_date date NOT NULL,
    agreed_delivery_date date NOT NULL,
    agreed_delivery_location_id int NOT NULL,
    FOREIGN KEY (sales_staff_id) REFERENCES dim_staff(staff_id),
    FOREIGN KEY (counterparty_id) REFERENCES dim_counterparty(counterparty_id),
    FOREIGN KEY (currency_id) REFERENCES dim_currency(currency_id),
    FOREIGN KEY (design_id) REFERENCES dim_design(design_id),
    FOREIGN KEY (agreed_delivery_location_id) REFERENCES dim_location(location_id)
);
CREATE TABLE fact_purchase_order (
    purchase_record_id SERIAL PRIMARY KEY,
    purchase_order_id int NOT NULL,
    created_date date NOT NULL,
    created_time time NOT NULL,
    last_updated_date date NOT NULL,
    last_updated_time time NOT NULL,
    staff_id int NOT NULL,
    counterparty_id int NOT NULL,
    item_code varchar NOT NULL,
    item_quantity int NOT NULL,
    item_unit_price numeric NOT NULL,
    currency_id int NOT NULL,
    agreed_delivery_date date NOT NULL,
    agreed_payment_date date NOT NULL,
    agreed_delivery_location_id int NOT NULL,
    FOREIGN KEY (staff_id) REFERENCES dim_staff(staff_id),
    FOREIGN KEY (counterparty_id) REFERENCES dim_counterparty(counterparty_id),
    FOREIGN KEY (currency_id) REFERENCES dim_currency(currency_id),
    FOREIGN KEY (agreed_delivery_location_id) REFERENCES dim_location(location_id)
);
CREATE TABLE dim_payment_type (
    payment_type_id int PRIMARY KEY,
    payment_type_name varchar NOT NULL
);
CREATE TABLE fact_payment (
    payment_record_id SERIAL PRIMARY KEY,
    payment_id int NOT NULL,
    created_date date NOT NULL,
    created_time time NOT NULL,
    last_updated_date date NOT NULL,
    last_updated_time time NOT NULL,
    transaction_id int NOT NULL,
    counterparty_id int NOT NULL,
    payment_amount numeric NOT NULL,
    currency_id int NOT NULL,
    payment_type_id int NOT NULL,
    paid boolean NOT NULL,
    payment_date date NOT NULL,
    FOREIGN KEY (transaction_id) REFERENCES dim_transaction(transaction_id),
    FOREIGN KEY (counterparty_id) REFERENCES dim_counterparty(counterparty_id),
    FOREIGN KEY (currency_id) REFERENCES dim_currency(currency_id),
    FOREIGN KEY (payment_type_id) REFERENCES dim_payment_type(payment_type_id)
);
CREATE TABLE dim_transaction (
    transaction_id int PRIMARY KEY,
    transaction_type varchar NOT NULL,
    sales_order_id int,
    purchase_order_id int,
    FOREIGN KEY (sales_order_id) REFERENCES fact_sales_order(sales_order_id),
    FOREIGN KEY (purchase_order_id) REFERENCES fact_purchase_order(purchase_order_id)
);
INSERT INTO fact_sales_order (
    sales_order_id,
    created_date,
    created_time,
    last_updated_date,
    last_updated_time,
    sales_staff_id,
    counterparty_id,
    units_sold,
    unit_price,
    currency_id,
    design_id,
    agreed_payment_date,
    agreed_delivery_date,
    agreed_delivery_location_id
)
SELECT
    sales_order_id,
    DATE(created_at) AS created_date,
    TIME(created_at) AS created_time,
    DATE(last_updated) AS last_updated_date,
    TIME(last_updated) AS last_updated_time,
    staff_id AS sales_staff_id,
    counterparty_id,
    units_sold,
    unit_price,
    currency_id,
    design.design_id,
    DATE(agreed_payment_date) AS agreed_payment_date,
    DATE(agreed_delivery_date) AS agreed_delivery_date,
    address.address_id AS agreed_delivery_location_id
FROM
    totesys.dbo.sales_order
JOIN
    design ON sales_order.design_id = design.design_id
JOIN
    address ON sales_order.agreed_delivery_location_id = address.address_id;

INSERT INTO dim_date (
    date_id,
    year,
    month,
    day,
    day_of_week,
    day_name,
    month_name,
    quarter
)
SELECT
    ?? AS date_id, --??
    YEAR(agreed_payment_date) AS year,
    MONTH(agreed_payment_date) AS month,
    DAY(agreed_payment_date) AS day,
    DATEPART(WEEKDAY, agreed_payment_date) AS day_of_week,
    DATENAME(WEEKDAY, agreed_payment_date) AS day_name,
    DATENAME(MONTH, agreed_payment_date) AS month_name,
    DATEPART(QUARTER, agreed_payment_date) AS quarter
FROM
    totesys.dbo.purchase_order;    

INSERT INTO dim_staff (
    staff_id,
    first_name,
    last_name,
    department_name,
    location,
    email_address
)
SELECT
    staff_id,
    first_name,
    last_name,
    department_name,
    department.location AS location,
    email_address
FROM
    totesys.dbo.staff
JOIN
    department ON staff.department_id = department.department_id;    

INSERT INTO fact_purchase_order (
    purchase_order_id,
    created_date,
    created_time,
    last_updated_date,
    last_updated_time,
    staff_id,
    counterparty_id,
    item_code,
    item_quantity,
    item_unit_price,
    currency_id,
    agreed_delivery_date,
    agreed_payment_date,
    agreed_delivery_location_id
)
SELECT
    purchase_order_id,
    DATE(created_at) AS created_date,
    TIME(created_at) AS created_time,
    DATE(last_updated) AS last_updated_date,
    TIME(last_updated) AS last_updated_time,
    staff_id,
    counterparty_id,
    item_code,
    item_quantity,
    item_unit_price,
    currency_id,
    DATE(agreed_delivery_date) AS agreed_delivery_date,
    DATE(agreed_payment_date) AS agreed_payment_date,
    agreed_delivery_location_id
FROM
    totesys.dbo.purchase_order;
-- JOIN
--     address ON purchase_order.agreed_delivery_location_id = address.address_id;    


INSERT INTO dim_payment_type (
    payment_type_id,
    payment_type_name
)
SELECT
    payment_type_id,
    payment_type.payment_type_name AS payment_type_name
FROM
    totesys.dbo.payment
JOIN
    payment_type ON payment.payment_type_id = payment_type.payment_type_id;    ;

INSERT INTO fact_payment (
    payment_id,
    created_date,
    created_time,
    last_updated_date,
    last_updated,
    transaction_id,
    counterparty_id,
    payment_amount,
    currency_id,
    payment_type_id,
    paid,
    payment_date
)
SELECT
    payment_id,
    DATE(created_at) AS created_date,
    TIME(created_at) AS created_time,
    DATE(last_updated) AS last_updated_date,
    TIME(last_updated) AS last_updated,
    transaction_id,
    counterparty_id,
    payment_amount,
    currency_id,
    payment_type_id,
    paid,
    DATE(payment_date) AS payment_date
FROM
    totesys.dbo.payment;
-- JOIN
--     counterparty ON payment.counterparty_id = counterparty.counterparty_id;    


INSERT INTO dim_transaction (
    transaction_id,
    transaction_type,
    sales_order_id,
    purchase_order_id
)
SELECT
    transaction_id,
    transaction_type,
    sales_order_id,
    purchase_order_id
FROM
    totesys.dbo.transaction;

INSERT INTO dim_counterparty (
    counterparty_id,
    counterparty_legal_name,
    counterparty_legal_address_line_1,
    counterparty_legal_address_line_2,
    counterparty_legal_district,
    counterparty_legal_city,
    counterparty_legal_postal_code,
    counterparty_legal_country,
    counterparty_legal_phone_number
)
SELECT
    counterparty_id,
    counterparty_legal_name,
    address.address_line_1 AS counterparty_legal_address_line_1,
    address.address_line_2 AS counterparty_legal_address_line_2,
    address.district AS counterparty_legal_district,
    address.city AS counterparty_legal_city,
    address.postal_code AS counterparty_legal_postal_code,
    address.country AS counterparty_legal_country,
    address.phone AS counterparty_legal_phone_number
FROM
    totesys.dbo.counterparty
JOIN
    address ON counterparty.legal_address_id = address.address_id;


INSERT INTO dim_currency (
    currency_id,
    currency_code,
    currency_name
)
SELECT
    currency_id
    currency_code,
    last_name AS currency_name --where to find it
FROM
    totesys.dbo.currency
JOIN purchase_order ON staff.staff_id = purchase_order.staff_id
JOIN purchase_order ON currency.currency_id = purchase_order.currency_id;     ;

INSERT INTO dim_design (
    design_id,
    design_name,
    file_location,
    file_name
)
SELECT
    design_id,
    design_name,
    file_location,
    file_name
FROM
    totesys.dbo.design;

INSERT INTO dim_location (
    location_id,
    address_line_1,
    address_line_2,
    district,
    city,
    postal_code,
    country,
    phone
)
SELECT
    location_id,
    address_line_1,
    address_line_2,
    district,
    city,
    postal_code,
    country,
    phone
FROM
    totesys.dbo.address;

