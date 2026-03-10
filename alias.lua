DemoFlexWindow = DemoFlexWindow or Adjustable.Container:new({
  name = "DemoFlexWindow",
  x = "30%", y = "30%",
  width = 400, height = 300,
  titleText = "FlexGrid Demo (Drag Me!)",
})

DemoInner = DemoInner or Geyser.Container:new({
  name = "DemoInner",
  x = 0, y = 0, width = "100%", height = "100%",
}, DemoFlexWindow)

DemoElements = {}
local colors = {"#e74c3c", "#3498db", "#2ecc71", "#f1c40f", "#9b59b6", "#e67e22"}

for i = 1, 15 do
  local color = colors[(i % #colors) + 1]
  
  local lbl = Geyser.Label:new({
    name = "DemoLabel_" .. i,
  }, DemoInner)
  
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
  
  table.insert(DemoElements, lbl)
end

DemoLayout = DemoLayout or DemoBox.FlexGrid:new({
  container = DemoInner,
  adjName = "DemoFlexWindow", -- Must match the Adjustable Container name!
  minWidth = 80,              -- Try to be at least 80px wide
  maxWidth = 150,             -- Don't stretch wider than 150px
  itemHeight = 50,            -- Fixed height of 50px
  spacingX = 5,               -- 5px gap between columns
  spacingY = 5                -- 5px gap between rows
})

DemoLayout:setElements(DemoElements)
DemoFlexWindow:show()
cecho("\n<green>Demo FlexGrid created! Drag the edges of the 'FlexGrid Demo' window to see it in action.\n")