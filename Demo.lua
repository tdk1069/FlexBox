-- ==============================================================================
-- FlexGrid Usage Demo
-- Description: Creates a draggable window and populates it with flexbox labels.
-- ==============================================================================

-- Create the outer window (Adjustable.Container allows the user to drag and resize it)
DemoFlexWindow = DemoFlexWindow or Adjustable.Container:new({
  name = "DemoFlexWindow",
  x = "30%", y = "30%",
  width = 400, height = 300,
  titleText = "FlexGrid Demo (Drag Me!)",
})

-- Create an inner Geyser container to hold the actual elements
DemoInner = DemoInner or Geyser.Container:new({
  name = "DemoInner",
  x = 0, y = 0, width = "100%", height = "100%",
}, DemoFlexWindow)

-- Generate some dummy elements to put in the grid
DemoElements = {}
local colors = {"#e74c3c", "#3498db", "#2ecc71", "#f1c40f", "#9b59b6", "#e67e22"}

for i = 1, 15 do
  local color = colors[(i % #colors) + 1]
  
  -- Create a label attached to the DemoInner container
  local lbl = Geyser.Label:new({
    name = "DemoLabel_" .. i,
  }, DemoInner)
  
  -- Add some styling so it looks nice
  lbl:setStyleSheet([[
    background-color: ]] .. color .. [[;
    border: 2px solid #2c3e50;
    border-radius: 6px;
    qproperty-alignment: 'AlignCenter';
    font-size: 14pt;
    font-weight: bold;
    color: white;
  ]])
  
  lbl:echo("Item " .. i)
  
  -- Store the label in our sequential table
  table.insert(DemoElements, lbl)
end

-- Initialize the FlexGrid manager
DemoLayout = DemoLayout or FlexGrid:new({
  container = DemoInner,             -- The Geyser container the items live in
  adjName = "DemoFlexWindow",        -- The exact string name of the Adjustable.Container (for resize tracking)
  minWidth = 80,                     -- Grid items will never be thinner than 80px
  maxWidth = 150,                    -- Grid items will stretch, but stop at 150px wide
  itemHeight = 50,                   -- Every item will be exactly 50px tall
  spacingX = 5,                      -- 5px horizontal gap between items
  spacingY = 5                       -- 5px vertical gap between rows
})

-- 5. Feed the elements to the layout manager
-- (This automatically positions them and triggers the first reflow)
DemoLayout:setElements(DemoElements)

-- 6. Show the window to the user
DemoFlexWindow:show()
cecho("\n<green>Demo FlexGrid created! Drag the edges of the 'FlexGrid Demo' window to see it in action.\n")
