DemoBox = DemoBox or {}

-- Create the FlexGrid Class
DemoBox.FlexGrid = DemoBox.FlexGrid or {}
DemoBox.FlexGrid.__index = DemoBox.FlexGrid

function DemoBox.FlexGrid:new(options)
  local fb = {
    name = options.name or "UnnamedFlexGrid",
    container = options.container, 
    adjName = options.adjName or (options.container and options.container.name),
    elements = {}, 
    
    minWidth = options.minWidth or 100,
    maxWidth = options.maxWidth or 150,
    itemHeight = options.itemHeight or 75,
    spacingX = options.spacingX or 5, 
    spacingY = options.spacingY or 5, 
    
    handlers = {},
    resizeTimer = nil,
    pendingReflow = false
  }
  setmetatable(fb, DemoBox.FlexGrid)

local function throttledReflow()
    -- If a timer is running, flag that we need an update, but do nothing else yet
    if fb.resizeTimer then 
      fb.pendingReflow = true
      return 
    end
    
    -- If no timer is running, update the UI immediately!
    fb:reflow()
    
    -- Start a 0.05s cooldown timer
    fb.resizeTimer = tempTimer(0.05, function()
      fb.resizeTimer = nil
      if fb.pendingReflow then
        fb.pendingReflow = false
        fb:reflow()
      end
    end)
  end

  fb.handlers.sysResize = registerAnonymousEventHandler("sysWindowResizeEvent", throttledReflow)
  fb.handlers.adjResize = registerAnonymousEventHandler("AdjustableContainerReposition", function(_, eventWindowName) 
    if eventWindowName == fb.adjName then throttledReflow() end 
  end)
  
  return fb
end

function DemoBox.FlexGrid:setElements(elementList)
  self.elements = elementList
  self:reflow()
end

function DemoBox.FlexGrid:reflow()
  if not self.container or #self.elements == 0 then return end
  
  local cWidth = self.container:get_width()
  local cHeight = self.container:get_height()
  if cWidth <= 0 then return end
  
  -- Calculate Columns based on minWidth and spacing
  local columns = math.floor((cWidth + self.spacingX) / (self.minWidth + self.spacingX))
  if columns < 1 then columns = 1 end
  
  -- Distribute remaining width (up to maxWidth)
  local totalSpacing = (columns - 1) * self.spacingX
  local availableWidth = cWidth - totalSpacing
  local calculatedWidth = availableWidth / columns
  local actualWidth = math.max(self.minWidth, math.min(self.maxWidth, calculatedWidth))

  -- Position and Resize each element
  for index, el in ipairs(self.elements) do
    local mathIndex = index - 1 
    local col = mathIndex % columns
    local row = mathIndex / columns
    row = row - (row % 1) 
    
    local x = col * (actualWidth + self.spacingX)
    local y = row * (self.itemHeight + self.spacingY)
    
    if (y + self.itemHeight) > cHeight then
      el:hide()
    else
      el:resize(actualWidth, self.itemHeight)
      el:move(x, y)
      el:show()
    end
  end
end