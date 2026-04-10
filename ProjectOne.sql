-- Enforce Constraints on dim_cargo_measurement
ALTER TABLE dbo.dim_cargo_measurement
ALTER COLUMN identifier BIGINT NOT NULL;
GO
ALTER TABLE dbo.dim_cargo_measurement
ADD CONSTRAINT PK_dim_cargo_measurement
PRIMARY KEY (identifier);

-- Enforce Constraints on dim_consignee
ALTER TABLE dbo.dim_consignee
ALTER COLUMN consignee_id BIGINT NOT NULL;
GO
ALTER TABLE dbo.dim_consignee
ADD CONSTRAINT PK_dim_consignee
PRIMARY KEY (consignee_id);

-- Enforce Constraints on dim_port
ALTER TABLE dbo.dim_port
ALTER COLUMN port_id BIGINT NOT NULL;
GO
ALTER TABLE dbo.dim_port
ADD CONSTRAINT PK_dim_port
PRIMARY KEY (port_id);

-- Enforce Constraints on dim_shipper
ALTER TABLE dbo.dim_shipper
ALTER COLUMN shipper_id BIGINT NOT NULL;
GO
ALTER TABLE dbo.dim_shipper
ADD CONSTRAINT PK_dim_shipper
PRIMARY KEY (shipper_id);

-- Enforce Constraints on dim_vessel
ALTER TABLE dbo.dim_vessel
ALTER COLUMN vessel_id BIGINT NOT NULL;
GO
ALTER TABLE dbo.dim_vessel
ADD CONSTRAINT PK_dim_vessel
PRIMARY KEY (vessel_id);

-- Enforce Constraints on fact_header 
ALTER TABLE dbo.fact_header
ALTER COLUMN identifier BIGINT NOT NULL;
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT PK_fact_header
PRIMARY KEY NONCLUSTERED (identifier);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_port_of_unlading
FOREIGN KEY (port_of_unlading_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_foreign_port_lading_qualifier
FOREIGN KEY (foreign_port_of_lading_qualifier_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_foreign_port_of_lading
FOREIGN KEY (foreign_port_of_lading_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_port_of_destination
FOREIGN KEY (port_of_destination_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_foreign_port_of_destination_qualifier
FOREIGN KEY (foreign_port_of_destination_qualifier_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_foreign_port_of_destination
FOREIGN KEY (foreign_port_of_destination_id)
REFERENCES dbo.dim_port(port_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_vessel
FOREIGN KEY (vessel_id)
REFERENCES dbo.dim_vessel(vessel_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_shipper
FOREIGN KEY (shipper_id)
REFERENCES dbo.dim_shipper(shipper_id);
GO
ALTER TABLE dbo.fact_header
ADD CONSTRAINT FK_fact_header_consignee
FOREIGN KEY (consignee_id)
REFERENCES dbo.dim_consignee(consignee_id);


-- Creating View: Top Exporters By Shipping Company
CREATE OR ALTER VIEW dbo.top_exporters_by_shipper
AS
SELECT
    s.shipper_id,
    s.shipper_party_name AS shipper_name,
    COUNT(DISTINCT fh.identifier) AS shipment_count,
    SUM(fh.manifest_quantity) AS total_manifest_quantity
FROM dbo.fact_header fh
JOIN dbo.dim_shipper s
    ON fh.shipper_id = s.shipper_id
GROUP BY
    s.shipper_id,
    s.shipper_party_name;

SELECT *
FROM dbo.top_exporters_by_shipper
ORDER BY shipment_count DESC;

-- Creating View: Top Exporters By Consignee Company
CREATE OR ALTER VIEW dbo.top_exporters_by_consignee
AS
SELECT
    c.consignee_id,
    c.consignee_name,
    COUNT(DISTINCT fh.identifier) AS shipment_count,
    SUM(fh.manifest_quantity) AS total_manifest_quantity
FROM dbo.fact_header fh
JOIN dbo.dim_consignee c
    ON fh.consignee_id = c.consignee_id
GROUP BY
    c.consignee_id,
    c.consignee_name;

SELECT *
FROM dbo.top_exporters_by_consignee
ORDER BY shipment_count DESC;

-- Creating View: Top Exporters By Foreign Country
CREATE OR ALTER VIEW dbo.top_exporters_by_country
AS
SELECT
    p.port_id,
    p.port_name AS export_country,
    COUNT(DISTINCT fh.identifier) AS shipment_count,
    SUM(fh.manifest_quantity) AS total_manifest_quantity
FROM dbo.fact_header fh
JOIN dbo.dim_port p
    ON fh.foreign_port_of_lading_id = p.port_id
GROUP BY
    p.port_id,
    p.port_name;

SELECT *
FROM dbo.top_exporters_by_country
ORDER BY shipment_count DESC;
