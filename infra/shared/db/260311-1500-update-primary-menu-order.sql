-- Update Primary Menu order after adding "About Us" menu item
-- About Us should be first, followed by Register, Login, Profile, Help, Logout
UPDATE wp_posts 
SET menu_order = CASE ID 
    WHEN 96 THEN 1  -- About Us
    WHEN 37 THEN 2  -- Register
    WHEN 40 THEN 3  -- Login
    WHEN 38 THEN 4  -- Profile
    WHEN 39 THEN 5  -- Help
    WHEN 41 THEN 6  -- Logout
END 
WHERE ID IN (96, 37, 40, 38, 39, 41);
