CREATE FUNCTION [dbo].[geomToGeoJSON] (@geom GEOMETRY)
RETURNS VARCHAR(MAX)
AS
BEGIN
-- Declare the return variable here
    DECLARE @geoJSON VARCHAR(MAX)


    DECLARE @Ngeom GEOMETRY
    DECLARE @ptCounter INT
    DECLARE @numPt INT
    DECLARE @ringCounter INT
    DECLARE @numRing INT
    DECLARE @gCounter INT
    DECLARE @numGeom INT
    DECLARE @handled BIT = 0
    DECLARE @extRing GEOMETRY
    DECLARE @intRing GEOMETRY

    -- fix bad geometries and enforce ring orientation
    SET @geom = @geom.STUnion(@geom.STPointN(1)).MakeValid()

    -- Point ----------------------------
    IF (@geom.STGeometryType() = 'Point')
    BEGIN
        SET @geoJSON = '{ "type": "Point", "coordinates": [' + LTRIM(RTRIM(STR(@geom.STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@geom.STY, 38, 8))) + '] }'
        SET @handled = 1
    END


    -- MultiPoint ---------------------------------------------
    IF (
        @handled = 0
        AND @geom.STGeometryType() = 'MultiPoint'
        )
    BEGIN
        SET @gCounter = 1
        SET @numGeom = @geom.STNumGeometries()

        SET @geoJSON = '{ "type": "MultiPoint", "coordinates": ['

        WHILE @gCounter <= @numGeom
        BEGIN
            SET @geoJSON += '[' + LTRIM(RTRIM(STR(@geom.STGeometryN(@gCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@geom.STGeometryN(@gCounter).STY, 38, 8))) + '], '
            SET @gCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + '] }'
        SET @handled = 1
    END




    -- LineString ---------------------------------------------
    IF (
        @handled = 0
        AND @geom.STGeometryType() = 'LineString'
        )
    BEGIN
        SET @ptCounter = 1
        SET @numPt = @geom.STNumPoints()

        SET @geoJSON = '{ "type": "LineString", "coordinates": ['

        WHILE @ptCounter <= @numPt
        BEGIN
            SET @geoJSON += '[' + LTRIM(RTRIM(STR(@geom.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@geom.STPointN(@ptCounter).STY, 38, 8))) + '], '
            SET @ptCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ' ] }'
        SET @handled = 1
    END




    -- MultiLineString ---------------------------------------------
    IF (
        @handled = 0
        AND @geom.STGeometryType() = 'MultiLineString'
        )
    BEGIN
        SET @gCounter = 1
        SET @numGeom = @geom.STNumGeometries()

        SET @geoJSON = '{ "type": "MultiLineString", "coordinates": ['

        WHILE @gCounter <= @numGeom
        BEGIN
            SET @Ngeom = @geom.STGeometryN(@gCounter)
            SET @geoJSON += '['
            SELECT
                @ptCounter = 1
                ,@numPt = @Ngeom.STNumPoints()

            WHILE @ptCounter <= @numPt
            BEGIN
                SET @geoJSON += '[' + LTRIM(RTRIM(STR(@Ngeom.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@Ngeom.STPointN(@ptCounter).STY, 38, 8))) + '], '
                SET @ptCounter += 1
            END

            SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + '],'

            SET @gCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + '] }'
        SET @handled = 1
    END




    -- Polygon ---------------------------------------------
    IF (
        @handled = 0
        AND @geom.STGeometryType() = 'Polygon'
        )
    BEGIN
        SET @extRing = @geom.STExteriorRing()

        SET @geoJSON = '{ "type": "Polygon", "coordinates": [['

        SELECT
            @ptCounter = 1
            ,@numPt = @extRing.STNumPoints()

        WHILE @ptCounter <= @numPt
        BEGIN
            SET @geoJSON += '[' + LTRIM(RTRIM(STR(@extRing.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@extRing.STPointN(@ptCounter).STY, 38, 8))) + '], '
            SET @ptCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ']'

        SET @ringCounter = 1
        SET @numRing = @geom.STNumInteriorRing()

        WHILE @ringCounter <= @numRing
        BEGIN
            SET @geoJSON += ',['

            SET @intRing  @geom.STInteriorRingN(@ringCounter)
            -- set the ring orientation so that they are consistent
            SET @intRing = @intRing.STUnion(@intRing.STPointN(1)).MakeValid()

            SELECT
                @ptCounter = @intRing.STNumPoints()

            WHILE @ptCounter > 0
            BEGIN
                SET @geoJSON += '[' + LTRIM(RTRIM(STR(@intRing.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@intRing.STPointN(@ptCounter).STY, 38, 8))) + '], '
                SET @ptCounter -= 1
            END

            SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ']'

            SET @ringCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ']] }'
        SET @handled = 1
    END




    -- MultiPolygon ---------------------------------------------
    IF (
        @handled = 0
        AND @geom.STGeometryType() = 'MultiPolygon'
        )
    BEGIN
        SELECT
            @gCounter = 1
            ,@numGeom = @geom.STNumGeometries()

        SET @geoJSON = '{ "type": "MultiPolygon", "coordinates": ['

        WHILE @gCounter <= @numGeom
        BEGIN
            SET @Ngeom = @geom.STGeometryN(@gCounter)

            SET @extRing = @Ngeom.STExteriorRing()

            SET @geoJSON += '[['

            SELECT
                @ptCounter = 1
                ,@numPt = @extRing.STNumPoints()

            -- add the exterior ring points to the json
            WHILE @ptCounter <= @numPt
            BEGIN
                SET @geoJSON += '[' + LTRIM(RTRIM(STR(@extRing.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@extRing.STPointN(@ptCounter).STY, 38, 8))) + '], '
                SET @ptCounter += 1
            END

            SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ']'

            SET @ringCounter = 1
            SET @numRing = @Ngeom.STNumInteriorRing()

            -- add any internal ring points to the json
            WHILE @ringCounter <= @numRing
            BEGIN
                SET @geoJSON += ',['

                SET @intRing = @Ngeom.STInteriorRingN(@ringCounter)
                -- make sure the ring orientation is the same every time
                SET @intRing = @intRing.STUnion(@intRing.STPointN(1)).MakeValid()

                SELECT
                    @ptCounter = @intRing.STNumPoints()

                WHILE @ptCounter > 0
                BEGIN
                    SET @geoJSON += '[' + LTRIM(RTRIM(STR(@intRing.STPointN(@ptCounter).STX, 38, 8))) + ', ' + LTRIM(RTRIM(STR(@intRing.STPointN(@ptCounter).STY, 38, 8))) + '], '
                    SET @ptCounter -= 1
                END

                SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + ']'

                SET @ringCounter += 1
            END



            SET @geoJSON += '],'
            SET @gCounter += 1
        END

        SET @geoJSON = LEFT(@geoJSON, LEN(@geoJSON) - 1) + '] }'
        SET @handled = 1
    END






    IF (@handled = 0)
    BEGIN
        SET @geoJSON = '{"type": "' + @geom.STGeometryType() + '", "coordinates": []}'
    END




    RETURN @geoJSON



END

