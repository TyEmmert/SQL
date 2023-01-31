-- Create the tables
CREATE TABLE target (                   -- Create table named "target"
    id INTEGER NOT NULL AUTO_INCREMENT, -- First column for integers, not null, and keep it in order.
    val VARCHAR(255),                   -- Second column for characters.
    PRIMARY KEY (id)
);

CREATE TABLE source (                   -- Create table named "source"
    id INTEGER NOT NULL AUTO_INCREMENT, -- First column for integers, not null, and keep it in order.
    val VARCHAR(255),                   -- Second column for characters.
    PRIMARY KEY (id)
);

CREATE TABLE result (                   -- Create table named "result"
    id INTEGER NOT NULL AUTO_INCREMENT, -- First column for integers, not null, and keep it in order.
    val VARCHAR(255),                   -- Second column for characters.
    PRIMARY KEY (id)
);

CREATE TABLE result1 (                  -- Create table named "result1" for the UPDATE code that uses a temporary table
    id INTEGER NOT NULL AUTO_INCREMENT, -- First column for integers, not null, and keep it in order.
    val VARCHAR(255),                   -- Second column for characters.
    PRIMARY KEY (id)
);
-- Insert values into the tables
INSERT INTO
    target (id, val)                    -- Insert two columns "id" and "val"
VALUES                                  -- Fill id with 1, 2, ... and fill val with A, A, ...
    (1, 'A'),
    (2, 'A'),
    (3, NULL),
    (5, 'A'),
    (8, 'A'),
    (9, NULL),
    (10, NULL);

INSERT INTO                             -- Insert two columns "id" and "val"
    source (id, val)                    -- Fill id with 1, 2, ... and fill val with NULL, B, ...
VALUES
    (1, NULL),
    (2, 'B'),
    (4, 'B'),
    (8, 'B'),
    (9, 'B'),
    (10, NULL),
    (11, NULL);

INSERT INTO                             -- Insert all the columns from target into result
    result (
        SELECT
            *
        FROM
            target
    );

-------------------------- UPDATE
CREATE TEMPORARY TABLE result1 (select * from result); -- Create a temporary table called result1 with all the columns from the result table.
UPDATE result1                                         -- Update the result1 table 
LEFT JOIN source ON result1.id = source.id             -- Joins source on result1.id
SET result1.val = source.val                           -- Set the val column of result1 to source.val
WHERE result1.id = source.id;                          -- Where result1 ids and source ids are the same


-------------------------- MERGE
SELECT
    result.id,                                        -- Select result.id
    CASE                                              -- Create conditions for the val column
        WHEN source.val IS NULL                       -- When the val column is null for source
        AND source.id IS NULL                         -- and the id for source is null
        THEN result.val                               -- then use val from result
        ELSE source.val                               -- everything else should be filled with val from source
    END AS val                                        -- end as a val column
FROM
    result                                            -- Clear conditions to use result.id
    LEFT JOIN source ON result.id = source.id         -- Join all the values from source onto the result table with matching id
UNION                                                 -- Create a union to establish an outer join
SELECT
    source.id,                                        -- Select column source.id
    CASE                                              -- Create conditions for the val column
        WHEN source.val IS NULL THEN source.val       -- If val column for source is null then use val the null value
        ELSE source.val                               -- fill the rest of the columns with source.val
        END AS val                                    -- end as a val column
FROM 
    source                                            -- select table to pull source.id from
LEFT JOIN result ON result.id = source.id             -- Join all the values from result onto the source table with matching id
ORDER BY id;                                          -- Arrange in numerical order.

------------------------- APPEND
--INSERT INTO result (this will change the table)
SELECT *                                              -- Select all columns
FROM result                                           -- From result
UNION ALL                                             -- Outer join but keep duplicates.
SELECT *                                              -- Select all columns
FROM source                                           -- From source
ORDER BY id;                                          -- Arrange in numerical order.


-------------------- UPDATE_NULL_FILL

SELECT 
    result.id,                                     -- Select id column for result
    CASE                                           -- Create conditions for val column
    WHEN result.val IS NULL                        -- If val column in result table is null
    THEN source.val                                -- Then use val column from source
    ELSE result.val                                -- Fill the rest of the column with val column from result
    END AS val                                     -- store results in val column
FROM 
    result                                         -- for result.id conditions
LEFT JOIN source ON result.id = source.id;         -- Join all the values from source onto the result table with matching id

------------------- UPDATE_OVERRIDE
SELECT result.id,                                  -- Select id column from result.
    CASE                                           -- Create conditions for val column
    WHEN source.val IS NULL                        -- When val column in source is null
    THEN result.val                                -- then use val column from result.
    ELSE source.val                                -- Fill everything else with val from source.
    END AS val                                     -- establish the column as val.
FROM
    result                                         -- Condition to use result.id
LEFT JOIN source ON result.id = source.id;         -- Join all the values from source onto the result table with matching id

-------------------- merge_null_fill
SELECT result.id,                                  -- Select id column from result.
    CASE                                           -- Create conditons for a new val column
    WHEN result.val IS NULL                        -- When val column for result is null
    THEN source.val                                -- then use val column from source
    ELSE result.val                                -- else use val column from result
    END AS val                                     -- Establish the val column
FROM
    result                                         -- To pull result.id for result.
LEFT JOIN source ON result.id = source.id          -- Join all the values from source onto the result table with matching id
UNION                                              -- Create an outer join, and do not keep duplicates.
SELECT
    source.id,                                     -- Select id column from source
    CASE                                           -- Create conditions for a val column
    WHEN result.id IS NULL                         -- When id column in result is null
    AND result.val IS NULL                         -- and val column is also null
    THEN source.val                                -- then use val column from source
    ELSE result.val                                -- else use val column from result
    END AS val                                     -- end as the val column
FROM 
    source                                        -- to pull source.id
LEFT JOIN result ON result.id = source.id         -- Join all the values from result onto the source table with matching id
ORDER BY id;                                      -- Arrange the numbers in id in ascending order.

----------------- merge_override (WORKS)
SELECT
    result.id,                                    -- Select id column from result
    CASE                                          -- Create conditions for val column
        WHEN result.val IS NULL THEN source.val   -- When val column in result is null then use val column from source
        WHEN source.val IS NULL THEN result.val   -- When val column from source is null then use val column from result
        ELSE source.val                           -- else use val column from result
        END AS val                                -- End conditions as a val column
FROM 
    result                                        -- To pull result.id from result
LEFT JOIN source ON result.id = source.id
UNION                                             -- Create an outer join, and do not keep duplicates.
SELECT
    source.id,                                    -- Select id column from source.
    CASE                                          -- Create conditions for val column
    WHEN result.id IS NULL                        -- when id column in result is null
    AND result.val IS NULL                        -- and val column in result is also null
    THEN source.val                               -- then use val column from source
    WHEN source.val IS NULL                       -- when val column is null
    THEN result.val                               -- then use val from result.
    ELSE source.val                               -- Fill all other columns with val from source.
    END AS val                                    -- End conditions for val column
FROM 
    source                                        -- source table to use source.id in conditions
LEFT JOIN result ON result.id = source.id         -- Join all the values from result onto the source table with matching id
ORDER BY id;                                      -- Order by id.

