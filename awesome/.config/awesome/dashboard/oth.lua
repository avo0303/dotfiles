local power = require("power")

local M = {}

local create_button = function(icon, comm)
  local button = wibox.widget {
    {
      {
        widget = wibox.widget.textbox,
        font = beautiful.icofont,
        markup = help.fg(icon, beautiful.fg, "normal"),
        halign = "center",
        align = 'center',
      },
      margins = dpi(20),
      widget = wibox.container.margin,
    },
    bg = beautiful.bg2,
    buttons = { awful.button({}, 1, function()
      if type(comm) == "string" then
        awful.spawn(comm, false)
      else
        comm()
      end
    end) },
    shape = gears.shape.circle,
    widget = wibox.container.background,
  }
  button:connect_signal("mouse::enter", function()
    button.bg = beautiful.bg3
  end)
  button:connect_signal("mouse::leave", function()
    button.bg = beautiful.bg2
  end)
  return button
end

M.usr = wibox.widget {
  {
    image = beautiful.theme_dir .. "profile.png",
    resize = true,
    opacity = 0.8,
    forced_height = dpi(72),
    forced_width = dpi(72),
    clip_shape = gears.shape.circle,
    widget = wibox.widget.imagebox,
    halign = "center"
  },
  {
    {
      {
        markup = help.fg(os.getenv('USER'), beautiful.pri, "normal"),
        font = beautiful.fontname .. dpi(12),
        widget = wibox.widget.textbox,
        align = "center"
      },
      {
        markup = help.fg("arch", beautiful.fg, "normal"),
        font = beautiful.fontname .. dpi(10),
        widget = wibox.widget.textbox,
        align = "center"
      },
      spacing = dpi(0),
      layout = wibox.layout.fixed.vertical
    },
    widget = wibox.container.place,
    halign = "center",
  },
  -- spacing = dpi(4),
  layout = wibox.layout.fixed.vertical,
}

M.ses = wibox.widget {
  {
    {
      create_button("\u{f023}", function()
        dashboard.toggle()
        awful.spawn("betterlockscreen -l", false)
      end),
      create_button("\u{f011}", function()
        power.toggle()
        dashboard.toggle()
      end),
      spacing = dpi(12),
      layout = wibox.layout.fixed.horizontal,
    },
    widget = wibox.container.place,
    halign = "right",
  },
  layout = wibox.layout.flex.horizontal,
}

M.pfl = wibox.widget {
  {
    {
      {
        format = "%A, %B %e",
        refresh = 1,
        widget = wibox.widget.textclock,
        align = "center"
      },
      {
        format = "%H:%M:%S",
        refresh = 1,
        fg = beautiful.bg2,
        font = beautiful.fontname .. "14",
        align = "center",
        widget = wibox.widget.textclock
      },
      layout = wibox.layout.flex.vertical,
    },
    widget = wibox.container.margin,
    margins = dpi(20),
  },
  shape = help.rrect(beautiful.br),
  bg = beautiful.bg2,
  fg = beautiful.pri,
  widget = wibox.container.background,
}

M.cal = wibox.widget {
  {
    {
      {
        format = help.fg("%H:%M:%S", beautiful.pri, "1000"),
        refresh = 1,
        fg = beautiful.bg2,
        font = beautiful.fontname .. "12",
        halign = "left",
        valign = "top",
        widget = wibox.widget.textclock
      },
      {
        format = help.fg("%A,%e %B", beautiful.pri, "bold"),
        refresh = 1,
        widget = wibox.widget.textclock,
        font = beautiful.fontname .. "10",
        halign = "left",
        valign = "top"
      },
      spacing = dpi(0),
      layout = wibox.layout.fixed.vertical,
    },
    widget = wibox.container.background,
    margins = dpi(0),
  },
  -- shape = help.rrect(beautiful.br),
  bg = beautiful.bg1,
  fg = beautiful.pri,
  widget = wibox.container.background,
}

M.wth = wibox.widget {
  {
    {
      {
        {
          id = "icn",
          align = "left",
          font = beautiful.fontname .. "12",
          widget = wibox.widget.textbox
        },
        {
          {
            id = "wth",
            markup = "...",
            align = "right",
            font = beautiful.fontname .. "10",
            widget = wibox.widget.textbox
          },
          {
            id = "wnd",
            align = "right",
            font = beautiful.fontname .. "10",
            widget = wibox.widget.textbox
          },
          spacing = dpi(0),
          layout = wibox.layout.fixed.vertical,
        },
        layout = wibox.layout.flex.horizontal
      },
      widget = wibox.container.margin,
      margins = dpi(8),
    },
    shape = help.rrect(beautiful.br),
    bg = beautiful.bg2,
    fg = beautiful.fg2,
    widget = wibox.container.background,
    -- forced_height = 40,
    forced_width = 128,
  },
  widget = wibox.container.place,
  halign = "left",
}

gears.timer {
  timeout = 10,
  single_shot = true,
  autostart = true,
  callback = function()
    -- m = ºC, km/h
    -- u = ºF, mph
    local unit = "m"
    local city
    local fallback_city = "alicante"
    awful.spawn.easy_async_with_shell("curl -s https://ipinfo.io/$(curl -s ifconfig.me) | jq -r .city",
      function(out)
        out = out:sub(1, -2)
        if out == "" then
          city = fallback_city
        else
          city = out
        end
        local com = "curl 'wttr.in/" .. city .. "?" .. unit .. "&format=%c+%t+%w'"

        awful.widget.watch(com, 600, function(widget, out)
          local val = gears.string.split(out, " ")
          local sign = val[2]:sub(1, 1)

          M.wth:get_children_by_id("icn")[1].markup = val[1]
          M.wth:get_children_by_id("wth")[1].markup = help.fg(
            (sign == "-" and "-" or "") .. val[2]:sub(2),
            beautiful.pri, "1000")
          M.wth:get_children_by_id("wnd")[1].markup = help.fg(val[3]:sub(1, -2), beautiful.fg2, "bold")
        end)
      end)
  end
}

return M
