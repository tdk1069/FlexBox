-- ==============================================================================
-- FlexGrid for Mudlet
-- Description: A responsive grid layout manager for Geyser/Adjustable Containers.
-- ==============================================================================

FlexGrid = FlexGrid or {}
FlexGrid.__index = FlexGrid

--- Creates a new FlexGrid layout manager.
-- @param options Table of configuration options:
--   container: (Required) The Geyser container the elements reside in.
--   name: (Optional) String name for this grid instance.
--   adjName: (Optional) String name of the parent Adjustable.Container (if used) to track resizes.
--   minWidth: (Optional) Minimum width of a grid item (default: 100).
--   maxWidth: (Optional) Maximum width of a grid item before making a new column (default: 150).
--   itemHeight: (Optional) Fixed height for grid items (default: 75).
--   spacingX: (Optional) Horizontal gap between items (default: 5).
--   spacingY: (Optional) Vertical gap between rows (default: 5).
function FlexGrid:new(options)
  local fg = {
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
  setmetatable(fg, FlexGrid)

  -- Throttled reflow prevents lag when users are actively dragging window edges
  local function throttledReflow()
    if fg.resizeTimer then 
      fg.pendingReflow = true
      return 
    end
    
    fg:reflow()
    
    fg.resizeTimer = tempTimer(0.02, function()
      fg.resizeTimer = nil
      if fg.pendingReflow then
        fg.pendingReflow = false
        fg:reflow()
      end
    end)
  end

  -- Listen for main Mudlet window resizes
  fg.handlers.sysResize = registerAnonymousEventHandler("sysWindowResizeEvent", throttledReflow)
  
  -- Listen for Adjustable Container resizes (if applicable)
  fg.handlers.adjResize = registerAnonymousEventHandler("AdjustableContainerReposition", function(_, eventWindowName) 
    if eventWindowName == fg.adjName then throttledReflow() end 
  end)
  
  return fg
end

--- Assigns a table of Geyser elements to the grid and triggers an initial reflow.
-- @param elementList A sequential table of Geyser UI objects.
function FlexGrid:setElements(elementList)
  self.elements = elementList
  self:reflow()
end

--- Calculates layout mathematics and repositions all elements.
function FlexGrid:reflow()
  if not self.container or #self.elements == 0 then return end
  
  local cWidth = self.container:get_width()
  local cHeight = self.container:get_height()
  if cWidth <= 0 then return end
  
  -- Calculate how many columns can fit based on minWidth and spacing
  local columns = math.floor((cWidth + self.spacingX) / (self.minWidth + self.spacingX))
  if columns < 1 then columns = 1 end
  
  -- Distribute remaining width to stretch items (up to maxWidth)
  local totalSpacing = (columns - 1) * self.spacingX
  local availableWidth = cWidth - totalSpacing
  local calculatedWidth = availableWidth / columns
  local actualWidth = math.max(self.minWidth, math.min(self.maxWidth, calculatedWidth))

  -- Loop through elements to assign positions and sizes
  for index, el in ipairs(self.elements) do
    local mathIndex = index - 1 
    local col = mathIndex % columns
    local row = mathIndex / columns
    row = row - (row % 1) -- Remove fractional part for integer row number
    
    local x = col * (actualWidth + self.spacingX)
    local y = row * (self.itemHeight + self.spacingY)
    
    -- Hide elements that spill past the bottom of the container
    if (y + self.itemHeight) > cHeight then
      el:hide()
    else
      el:resize(actualWidth, self.itemHeight)
      el:move(x, y)
      el:show()
    end
  end
end
