create table user_master
(
    id                 int auto_increment
        primary key,
    email_address      varchar(64)                                          not null,
    password_hash      text                                                 null,
    password_expiry    date                                                 null,
    telephone_number   varchar(24)                                          null,
    account_status     enum ('A', 'P', 'B', 'S')  default 'P'               null comment 'Active, pending, blocked, suspended',
    user_name_first    text                                                 null,
    user_name_last     text                                                 null,
    user_gender        enum ('M', 'F', 'NB', 'U') default 'U'               null,
    user_date_of_birth date                                                 null,
    user_nationality   char(2)                                              null,
    profile_status_msg text                                                 null,
    user_type          enum ('ONAUT', 'CLIENT')   default 'CLIENT'          null,
    created_by         int                                                  null,
    created_at         datetime                   default CURRENT_TIMESTAMP null,
    updated_at         datetime                   default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint user_master_pk
        unique (email_address),
    constraint user_master_pk_2
        unique (telephone_number),
    constraint user_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table business_type
(
    id               int auto_increment
        primary key,
    main_type        varchar(24)                        null,
    type_name        varchar(255)                       null,
    type_local_names text                               null,
    created_by       int                                null,
    created_at       datetime default CURRENT_TIMESTAMP null,
    updated_at       datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint business_type_pk
        unique (type_name),
    constraint business_type_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index business_type_main_type_index
    on business_type (main_type);

create table customer_master
(
    id               int auto_increment
        primary key,
    email_address    varchar(64)                                    not null,
    telephone_number varchar(24)                                    null,
    customer_name    varchar(255)                                   null,
    is_active        enum ('A', 'I', 'D') default 'A'               not null,
    created_by       int                                            null,
    created_at       datetime             default CURRENT_TIMESTAMP null,
    updated_at       datetime             default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint customer_master_pk
        unique (email_address),
    constraint customer_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index customer_master_telephone_number_index
    on customer_master (telephone_number);

create table log_activity
(
    id               bigint auto_increment
        primary key,
    activity_key     varchar(32)                        null,
    table_involved   varchar(128)                       null,
    table_id_updated int      default 0                 null,
    activity_detail  text                               null,
    created_by       int                                null,
    created_at       datetime default CURRENT_TIMESTAMP null,
    updated_at       datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint log_activity_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index log_activity_table_id_updated_index
    on log_activity (table_id_updated);

create index log_activity_table_involved_index
    on log_activity (table_involved);

create table standard_country
(
    id                     char(2)                                         not null comment 'ISO3166 Alpha-2 Code'
        primary key,
    continent_code         enum ('asia-southeast', 'asia-east', 'oceania') null comment 'To be updated with more regions when needed',
    column_name            varchar(128)                                    null comment 'Generic name',
    country_local_name     varchar(255)                                    null comment 'Generic name',
    telephone_calling_code varchar(6)                                      null,
    country_status         enum ('ON', 'OFF') default 'OFF'                null,
    created_by             int                                             null,
    created_at             datetime           default CURRENT_TIMESTAMP    null,
    updated_at             datetime           default CURRENT_TIMESTAMP    null on update CURRENT_TIMESTAMP,
    constraint standard_country_uq
        unique (column_name),
    constraint standard_country_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table customer_address
(
    id             int auto_increment
        primary key,
    customer_id    int                                null,
    address_line_1 text                               null,
    address_line_2 text                               null,
    address_line_3 text                               null,
    address_city   text                               null,
    country_code   char(2)                            null,
    postal_code    varchar(16)                        null,
    created_by     int                                null,
    created_at     datetime default CURRENT_TIMESTAMP null,
    updated_at     datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint customer_address_customer_master_id_fk
        foreign key (customer_id) references customer_master (id),
    constraint customer_address_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint customer_address_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table otternaut_packages
(
    id                    int auto_increment
        primary key,
    country_code          char(2)                            null,
    package_name          varchar(128)                       null,
    package_monthly_price decimal(12, 2)                     null comment 'validity +30 days',
    package_annual_price  decimal(12, 2)                     null comment 'validity +365 days',
    created_by            int                                null,
    created_at            datetime default CURRENT_TIMESTAMP null,
    updated_at            datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint otternaut_packages_pk
        unique (country_code, package_name),
    constraint otternaut_packages_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint otternaut_packages_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table standard_city
(
    id               int auto_increment
        primary key,
    country_code     char(2)                            null,
    city_name        varchar(128)                       null,
    city_local_names text                               null,
    created_by       int                                null,
    created_at       datetime default CURRENT_TIMESTAMP null,
    updated_at       datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint standard_city_pk_2
        unique (city_name, country_code),
    constraint standard_city_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint standard_city_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index standard_country_telephone_calling_code_index
    on standard_country (telephone_calling_code);

create table standard_currency
(
    id                  char(3)                                    not null comment 'ISO4217 Code'
        primary key,
    country_code        char(2)                                    null comment 'ISO3166 code - if the currency is tied to a country, leave empty otherwise',
    currency_name       varchar(128)                               null,
    currency_local_name varchar(255)                               null,
    currency_symbol     varchar(36)                                null comment 'Use # to represent the location of the monetary amount along with th symbol',
    decimal_places      tinyint unsigned default '2'               null,
    thousand_separator  varchar(4)       default ','               null,
    decimal_point       varchar(4)       default '.'               null,
    created_by          int                                        null,
    created_at          datetime         default CURRENT_TIMESTAMP null,
    updated_at          datetime         default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint standard_currency_uq
        unique (currency_name),
    constraint standard_currency_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint standard_currency_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    comment 'ISO 4217' collate = utf8mb4_unicode_ci;

create table business_master
(
    id                   int auto_increment
        primary key,
    business_type_id     int                                       not null,
    business_name        varchar(255)                              null,
    business_slug        varchar(64)                               null,
    business_local_names text                                      null,
    country_code         char(2)                                   not null,
    currency_code        char(3)                                   not null,
    tax_percentage       decimal(5, 2)                             null,
    tax_inclusive        enum ('I', 'E') default 'I'               null,
    contract_expiry      date                                      null,
    created_by           int                                       null,
    created_at           datetime        default CURRENT_TIMESTAMP null,
    updated_at           datetime        default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint business_master_pk
        unique (business_name),
    constraint business_master_pk_2
        unique (business_slug),
    constraint business_master_business_type_id_fk
        foreign key (business_type_id) references business_type (id),
    constraint business_master_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint business_master_standard_currency_id_fk
        foreign key (currency_code) references standard_currency (id),
    constraint business_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table blog_category
(
    id                   int auto_increment
        primary key,
    business_id          int                                null,
    category_name        varchar(120)                       null,
    category_local_names text                               null,
    created_by           int                                null,
    created_at           datetime default CURRENT_TIMESTAMP null,
    updated_at           datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint blog_category_uq
        unique (category_name, business_id),
    constraint blog_category_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint blog_category_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table blog_master
(
    id                int auto_increment
        primary key,
    business_id       int                                       null,
    category_id       int                                       null,
    blog_locale       varchar(5)                                null,
    blog_slug         varchar(64)                               null,
    blog_title        text                                      null,
    blog_content      longtext                                  null,
    blog_status       enum ('D', 'P') default 'D'               null,
    blog_published_at datetime        default CURRENT_TIMESTAMP null comment 'If status is ''P'', it will be shown after this point in time',
    created_by        int                                       null,
    created_at        datetime        default CURRENT_TIMESTAMP null,
    updated_at        datetime        default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint blog_master_pk
        unique (blog_slug),
    constraint blog_master_blog_category_id_fk
        foreign key (category_id) references blog_category (id),
    constraint blog_master_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint blog_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table business_contract
(
    id               int auto_increment
        primary key,
    business_id      int                                                                        null,
    package_id       int                                                                        null,
    invoice_number   char(9)                                                                    null,
    contract_start   date                                                                       null,
    contract_expiry  date                                                                       null,
    invoiced_amount  decimal(12, 2)                                                             null,
    discount_amount  decimal(12, 2)                                                             null,
    total_amount     decimal(12, 2)                                                             null,
    paid_amount      decimal(12, 2)                                                             null,
    financial_status enum ('PENDING', 'PAID', 'REFUNDED', 'CANCELED') default 'PENDING'         null,
    created_by       int                                                                        null,
    created_at       datetime                                         default CURRENT_TIMESTAMP null,
    updated_at       datetime                                         default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint business_contract_invoice_number_uindex
        unique (invoice_number),
    constraint business_contract_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint business_contract_otternaut_packages_id_fk
        foreign key (package_id) references otternaut_packages (id),
    constraint business_contract_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table business_contract_payment
(
    id             int auto_increment
        primary key,
    contract_id    int                                                                       null,
    amount_paid    decimal(12, 2)                                                            null,
    payment_method enum ('CASH', 'TRANSFER', 'PROMPTPAY', 'OTHER') default 'CASH'            null,
    payment_notes  text                                                                      null,
    staff_comment  text                                                                      null,
    payment_status enum ('COMPLETE', 'FAIL', 'PENDING')            default 'PENDING'         null,
    created_by     int                                                                       null,
    created_at     datetime                                        default CURRENT_TIMESTAMP null,
    updated_at     datetime                                        default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint business_contract_payment_business_contract_id_fk
        foreign key (contract_id) references business_contract (id),
    constraint business_contract_payment_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table business_user
(
    id          int auto_increment
        primary key,
    business_id int                                                               not null,
    user_id     int                                                               not null,
    user_role   enum ('OWNER', 'MANAGER', 'STAFF')      default 'STAFF'           not null,
    role_status enum ('REQUESTED', 'ACTIVE', 'REVOKED') default 'REQUESTED'       not null,
    created_by  int                                                               null,
    created_at  datetime                                default CURRENT_TIMESTAMP null,
    updated_at  datetime                                default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint business_user_pk
        unique (business_id, user_id),
    constraint business_user_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint business_user_user_master_id_fk
        foreign key (user_id) references user_master (id),
    constraint business_user_user_master_id_fk_2
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index business_user_business_id_index
    on business_user (business_id);

create table order_master
(
    id                  int auto_increment
        primary key,
    business_id         int                                                                                                    null,
    customer_id         int                                                                                                    not null,
    customer_address_id int                                                                                                    null,
    order_number        char(12)                                                                                               not null,
    order_subtotal      decimal(12, 2)                                                                                         not null,
    order_adjustment    decimal(12, 2)                                                                                         not null comment 'mainly for tax and discount',
    order_total         decimal(12, 2)                                                                                         not null,
    order_status        enum ('OPEN', 'CLOSED', 'CANCELED')                                          default 'OPEN'            null,
    financial_status    enum ('PENDING', 'PAID', 'PARTIALLY_PAID', 'REFUNDED', 'PARTIALLY_REFUNDED') default 'PENDING'         null,
    shipping_status     enum ('OPEN', 'IN_PROGRESS', 'SHIPPED', 'RETURNED')                          default 'OPEN'            null,
    staff_comment       text                                                                                                   null,
    customer_comment    text                                                                                                   null,
    created_by          int                                                                                                    null,
    created_at          datetime                                                                     default CURRENT_TIMESTAMP null,
    updated_at          datetime                                                                     default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_master_pk
        unique (order_number),
    constraint order_master_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint order_master_customer_address_id_fk
        foreign key (customer_address_id) references customer_address (id),
    constraint order_master_customer_master_id_fk
        foreign key (customer_id) references customer_master (id),
    constraint order_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table order_line_adjustment
(
    id              int auto_increment
        primary key,
    order_id        int                                null,
    adjustment_type enum ('TAX', 'DISCOUNT')           null,
    line_detail     text                               null,
    line_amount     decimal(12, 2)                     null,
    created_by      int                                null,
    created_at      datetime default CURRENT_TIMESTAMP null,
    updated_at      datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_line_adjustment_order_master_id_fk
        foreign key (order_id) references order_master (id),
    constraint order_line_adjustment_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index order_master_business_id_index
    on order_master (business_id);

create table order_payment
(
    id             int auto_increment
        primary key,
    order_id       int                                                                                             null,
    amount_paid    decimal(12, 2)                                                                                  null,
    payment_method enum ('CASH', 'TRANSFER', 'PROMPTPAY', 'CREDIT_CARD', 'APP', 'OTHER') default 'CASH'            null,
    payment_notes  text                                                                                            null,
    staff_comment  text                                                                                            null,
    payment_status enum ('COMPLETE', 'FAIL', 'PENDING')                                                            null,
    created_by     int                                                                                             null,
    created_at     datetime                                                              default CURRENT_TIMESTAMP null,
    updated_at     datetime                                                              default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_payment_order_master_id_fk
        foreign key (order_id) references order_master (id),
    constraint order_payment_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table product_category
(
    id                   int auto_increment
        primary key,
    business_id          int                                null,
    category_name        varchar(255)                       null,
    category_local_names text                               null,
    created_by           int                                null,
    created_at           datetime default CURRENT_TIMESTAMP null,
    updated_at           datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint product_category_uq
        unique (category_name, business_id),
    constraint product_category_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint product_category_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table product_master
(
    id                   int auto_increment
        primary key,
    business_id          int                                                                  null,
    product_category_id  int                                                                  null,
    product_slug         char(9)                                                              null,
    product_name         varchar(255)                                                         null,
    product_local_names  text                                                                 null,
    product_tag          enum ('new', 'popular', 'recommended', '') default ''                null comment 'Just a label on the front page',
    product_type         enum ('P', 'D')                            default 'P'               null comment 'Physical or digital - delivery option will be available if ''P''',
    is_active            enum ('A', 'I', 'D')                       default 'A'               null,
    price_active_lowest  decimal(12, 2)                                                       null,
    price_compare_lowest decimal(12, 2)                                                       null,
    created_by           int                                                                  null,
    created_at           datetime                                   default CURRENT_TIMESTAMP null,
    updated_at           datetime                                   default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint product_master_uq
        unique (product_slug),
    constraint product_master_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint product_master_product_category_id_fk
        foreign key (product_category_id) references product_category (id),
    constraint product_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table product_variant
(
    id                  int auto_increment
        primary key,
    product_id          int                                null,
    variant_slug        char(9)                            null,
    variant_sku         varchar(60)                        null,
    variant_name        varchar(255)                       null,
    variant_local_names text                               null,
    is_active           enum ('A', 'I', 'D')               null,
    inventory_count     int      default 0                 null,
    price_active        decimal(12, 2)                     null,
    price_compare       decimal(12, 2)                     null,
    created_by          int                                null,
    created_at          datetime default CURRENT_TIMESTAMP null,
    updated_at          datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint product_variant_sku
        unique (product_id, variant_sku),
    constraint product_variant_uq
        unique (variant_slug),
    constraint product_variant_product_master_id_fk
        foreign key (product_id) references product_master (id),
    constraint product_variant_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table order_line_item
(
    id                   int auto_increment
        primary key,
    order_id             int                                       not null,
    product_variant_id   int                                       not null,
    product_name         varchar(255)                              null,
    product_variant_name varchar(255)                              null,
    line_quantity        int             default 1                 not null,
    unit_price           decimal(12, 2)                            not null,
    line_subtotal        decimal(12, 2)                            not null,
    item_need_delivery   enum ('Y', 'N') default 'N'               null,
    created_by           int                                       null,
    created_at           datetime        default CURRENT_TIMESTAMP null,
    updated_at           datetime        default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_line_item_order_master_id_fk
        foreign key (order_id) references order_master (id),
    constraint order_line_item_product_variant_id_fk
        foreign key (product_variant_id) references product_variant (id),
    constraint order_line_item_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index order_line_item_order_id_index
    on order_line_item (order_id);

create index product_variant_product_id_index
    on product_variant (product_id);

create table product_variant_inventory
(
    id              bigint auto_increment
        primary key,
    variant_id      int                                                        null,
    activity_key    enum ('buy', 'return', 'update') default 'buy'             null,
    quantity_change int                                                        null,
    new_inventory   int                                                        null,
    created_by      int                                                        null,
    created_at      datetime                         default CURRENT_TIMESTAMP null,
    updated_at      datetime                         default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint product_variant_inventory_product_variant_id_fk
        foreign key (variant_id) references product_variant (id),
    constraint product_variant_inventory_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table resource_type
(
    id                   int auto_increment
        primary key,
    business_id          int                                null,
    resource_type        varchar(255)                       null,
    resource_local_names text                               null,
    created_by           int                                null,
    created_at           datetime default CURRENT_TIMESTAMP null,
    updated_at           datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint resource_type_pk
        unique (business_id, resource_type),
    constraint resource_type_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint resource_type_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index resource_type_business_id_index
    on resource_type (business_id);

create table service_master
(
    id                   int auto_increment
        primary key,
    business_id          int                                            null,
    service_slug         char(9)                                        null comment 'Auto-generate slug from name',
    service_name         varchar(255)                                   null,
    service_local_names  text                                           null comment 'JSON service name in local languages',
    is_active            enum ('A', 'I', 'D') default 'A'               null,
    price_active_lowest  decimal(12, 2)                                 null comment 'auto-calculated',
    price_compare_lowest decimal(12, 2)                                 null comment 'auto-calculated',
    created_by           int                                            null,
    created_at           datetime             default CURRENT_TIMESTAMP null,
    updated_at           datetime             default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint service_master_uq
        unique (service_slug),
    constraint service_master_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint service_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table service_variant
(
    id                        int auto_increment
        primary key,
    service_id                int                                            null,
    variant_slug              char(9)                                        null comment 'Auto-generated slug from name',
    variant_name              varchar(255)                                   null,
    variant_local_names       text                                           null,
    is_active                 enum ('A', 'I', 'D') default 'A'               null,
    schedule_type             enum ('A', 'S')      default 'A'               null comment 'A for ad-hoc, S for scheduled sessions',
    variant_capacity          int                  default 1                 null comment 'Number of participants',
    price_active              decimal(12, 2)                                 null comment 'Active price',
    price_compare             decimal(12, 2)                                 null comment 'Full price',
    required_num_staff        int                  default 1                 null,
    required_resource_type_id int                                            null,
    service_duration_minutes  int                  default 60                null,
    created_by                int                                            null,
    created_at                datetime             default CURRENT_TIMESTAMP null,
    updated_at                datetime             default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint service_variant_uq
        unique (variant_slug),
    constraint service_variant_resource_master_id_fk
        foreign key (required_resource_type_id) references resource_type (id),
    constraint service_variant_service_master_id_fk
        foreign key (service_id) references service_master (id),
    constraint service_variant_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table order_booking_item
(
    id                   int auto_increment
        primary key,
    order_id             int                                null,
    service_variant_id   int                                null,
    service_name         varchar(255)                       null,
    service_variant_name varchar(255)                       null,
    booking_quantity     int      default 1                 null,
    unit_price           decimal(12, 2)                     null,
    booking_subtotal     decimal(12, 2)                     null,
    created_by           int                                null,
    created_at           datetime default CURRENT_TIMESTAMP null,
    updated_at           datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_booking_item_order_master_id_fk
        foreign key (order_id) references order_master (id),
    constraint order_booking_item_service_variant_id_fk
        foreign key (service_variant_id) references service_variant (id),
    constraint order_booking_item_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table review_master
(
    id                 int auto_increment
        primary key,
    customer_id        int                                null,
    service_variant_id int                                null,
    product_variant_id int                                null,
    review_stars       enum ('1', '2', '3', '4', '5')     null,
    review_messages    text                               null,
    created_by         int                                null,
    created_at         datetime default CURRENT_TIMESTAMP null,
    updated_at         datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint review_master_customer_master_id_fk
        foreign key (customer_id) references customer_master (id),
    constraint review_master_product_variant_id_fk
        foreign key (product_variant_id) references product_variant (id),
    constraint review_master_service_variant_id_fk
        foreign key (service_variant_id) references service_variant (id),
    constraint review_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table review_summary
(
    id                 int auto_increment
        primary key,
    service_variant_id int                                null,
    product_variant_id int                                null,
    review_count       int      default 0                 null,
    average_stars      int                                null comment 'times 1000',
    created_by         int                                null,
    created_at         datetime default CURRENT_TIMESTAMP null,
    updated_at         datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint review_summary_product_variant_id_fk
        foreign key (product_variant_id) references product_variant (id),
    constraint review_summary_service_variant_id_fk
        foreign key (service_variant_id) references service_variant (id),
    constraint review_summary_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index service_variant_service_id_index
    on service_variant (service_id);

create table session_master
(
    id                 int auto_increment
        primary key,
    service_variant_id int                                                 not null,
    session_type       enum ('OPEN', 'SPECIFIC') default 'SPECIFIC'        null,
    session_capacity   int                       default 1                 null comment 'If open, the number can be greater, waiting for people to book the session / if specific, the number is 1 and the session is for specific booking',
    short_description  varchar(255)                                        null,
    created_by         int                                                 null,
    created_at         datetime                  default CURRENT_TIMESTAMP null,
    updated_at         datetime                  default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint session_master_service_variant_id_fk
        foreign key (service_variant_id) references service_variant (id),
    constraint session_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table allocation_staff
(
    id              int auto_increment
        primary key,
    session_id      int                                                    not null,
    user_id         int                                                    not null,
    allocation_type enum ('SESSION', 'TIME_OFF') default 'SESSION'         not null,
    time_start      datetime                                               not null,
    time_end        datetime                                               not null,
    created_by      int                                                    null,
    created_at      datetime                     default CURRENT_TIMESTAMP null,
    updated_at      datetime                     default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint allocation_staff_pk
        unique (user_id, session_id),
    constraint allocation_staff_session_master_id_fk
        foreign key (session_id) references session_master (id),
    constraint allocation_staff_user_master_id_fk
        foreign key (user_id) references user_master (id),
    constraint allocation_staff_user_master_id_fk_2
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table order_booking_session
(
    id              int auto_increment
        primary key,
    session_id      int                                null,
    booking_item_id int                                null,
    created_by      int                                null,
    created_at      datetime default CURRENT_TIMESTAMP null,
    updated_at      datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint order_booking_session_pk
        unique (session_id, booking_item_id),
    constraint order_booking_session_order_booking_item_id_fk
        foreign key (booking_item_id) references order_booking_item (id),
    constraint order_booking_session_session_master_id_fk
        foreign key (session_id) references session_master (id),
    constraint order_booking_session_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table standard_locale
(
    id                  varchar(5)                         not null
        primary key,
    country_code        char(2)                            null,
    locale_name         varchar(255)                       null,
    locale_english_name varchar(128)                       null,
    created_by          int                                null,
    created_at          datetime default CURRENT_TIMESTAMP null,
    updated_at          datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint standard_locale_uq
        unique (locale_name),
    constraint standard_locale_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint standard_locale_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table standard_payment
(
    id                  int auto_increment
        primary key,
    country_code        char(2)                                                                  null,
    payment_name        varchar(64)                                                              null,
    payment_description text                                                                     null,
    payment_flow_type   enum ('MANUAL', 'AUTOMATED', 'SEMI-AUTOMATED') default 'MANUAL'          null,
    payment_status      enum ('ON', 'OFF')                             default 'OFF'             null,
    created_by          int                                                                      null,
    created_at          datetime                                       default CURRENT_TIMESTAMP null,
    updated_at          datetime                                       default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint standard_payment_pk_2
        unique (payment_name, country_code),
    constraint standard_payment_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint standard_payment_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table standard_timezone
(
    id              varchar(64)                               not null
        primary key,
    country_code    char(2)                                   null,
    timezone_offset char(6)                                   null,
    timezone_label  varchar(64)                               null,
    has_dst         enum ('Y', 'N') default 'N'               null,
    created_by      int                                       null,
    created_at      datetime        default CURRENT_TIMESTAMP null,
    updated_at      datetime        default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint standard_timezone_standard_country_id_fk
        foreign key (country_code) references standard_country (id),
    constraint standard_timezone_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table branch_master
(
    id                 int auto_increment
        primary key,
    business_id        int                                not null,
    city_id            int                                not null,
    branch_name        varchar(255)                       not null,
    branch_slug        char(9)                            not null,
    branch_local_names text                               null,
    timezone_code      varchar(64)                        not null,
    branch_type        enum ('PHYSICAL', 'ONLINE')        not null,
    branch_address     text                               null,
    created_by         int                                null,
    created_at         datetime default CURRENT_TIMESTAMP null,
    updated_at         datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint branch_master_pk
        unique (branch_name, business_id),
    constraint branch_master_pk_2
        unique (branch_slug),
    constraint branch_master_business_master_id_fk
        foreign key (business_id) references business_master (id),
    constraint branch_master_standard_city_id_fk
        foreign key (city_id) references standard_city (id),
    constraint branch_master_standard_timezone_id_fk
        foreign key (timezone_code) references standard_timezone (id),
    constraint branch_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table branch_off_dates
(
    id              int auto_increment
        primary key,
    branch_id       int                                null,
    off_date        date                               null,
    off_date_reason text                               null,
    created_by      int                                null,
    created_at      datetime default CURRENT_TIMESTAMP null,
    updated_at      datetime default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint branch_off_dates_pk
        unique (branch_id, off_date),
    constraint branch_off_dates_branch_master_id_fk
        foreign key (branch_id) references branch_master (id),
    constraint branch_off_dates_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index branch_off_dates_branch_id_index
    on branch_off_dates (branch_id);

create table branch_opening_hours
(
    id              int auto_increment
        primary key,
    branch_id       int                                        null,
    day_of_the_week enum ('M', 'T', 'W', 'TH', 'F', 'S', 'SU') null,
    opening_hours   time                                       null,
    closing_hours   time                                       null,
    created_by      int                                        null,
    created_at      datetime default CURRENT_TIMESTAMP         null,
    updated_at      datetime default CURRENT_TIMESTAMP         null on update CURRENT_TIMESTAMP,
    constraint branch_opening_hours_pk
        unique (branch_id, day_of_the_week),
    constraint branch_opening_hours_branch_master_id_fk
        foreign key (branch_id) references branch_master (id),
    constraint branch_opening_hours_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index branch_opening_hours_branch_id_index
    on branch_opening_hours (branch_id);

create table resource_master
(
    id                   int auto_increment
        primary key,
    branch_id            int                                            null,
    resource_type_id     int                                            null,
    resource_name        varchar(255)                                   null,
    resource_description text                                           null,
    is_active            enum ('A', 'I', 'D') default 'A'               null,
    created_by           int                                            null,
    created_at           datetime             default CURRENT_TIMESTAMP null,
    updated_at           datetime             default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint resource_master_pk
        unique (branch_id, resource_name),
    constraint resource_master_branch_master_id_fk
        foreign key (branch_id) references branch_master (id),
    constraint resource_master_resource_type_id_fk
        foreign key (resource_type_id) references resource_type (id),
    constraint resource_master_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create table allocation_resource
(
    id              int auto_increment
        primary key,
    session_id      int                                                     not null,
    resource_id     int                                                     not null,
    allocation_type enum ('SESSION', 'DOWN_TIME') default 'SESSION'         not null,
    time_start      datetime                                                not null,
    time_end        datetime                                                not null,
    created_by      int                                                     null,
    created_at      datetime                      default CURRENT_TIMESTAMP null,
    updated_at      datetime                      default CURRENT_TIMESTAMP null on update CURRENT_TIMESTAMP,
    constraint allocation_resource_pk
        unique (session_id, resource_id),
    constraint allocation_resource_resource_master_id_fk
        foreign key (resource_id) references resource_master (id),
    constraint allocation_resource_session_master_id_fk
        foreign key (session_id) references session_master (id),
    constraint allocation_resource_user_master_id_fk
        foreign key (created_by) references user_master (id)
)
    collate = utf8mb4_unicode_ci;

create index resource_master_branch_id_index
    on resource_master (branch_id);

create index standard_timezone_timezone_offset_index
    on standard_timezone (timezone_offset);

