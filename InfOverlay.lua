--natives
util.require_natives('1640181023')
local api_key = " " --If you have your own ipregistry api key put it in there.

--client resolution/aspect ratio
local resx, resy = directx.get_client_size()
local aspectratio <const> = resx/resy

--set position
local guix = 0
local guiy = 0

--set colours
local colour =
{
    titlebar = {r = 33/255, g = 30/255, b = 49/255, a = 255/255},
    background = {r = 33/255, g = 30/255, b = 49/255, a = 222/255},
    name = {r = 1, g = 1, b = 1, a = 1},
    label = {r = 1, g = 1, b = 1, a = 1},
    info = {r = 189/255, g = 135/255, b = 251/255, a = 255/255},
    border = {r = 189/255, g = 135/255, b = 251/255, a = 255/255}
}

--settings element sizing & spacing
local nameh = 0.022
local padding = 0.008
local spacing = 0.003
local textw = 0.16

--settings text sizing & spacing
local namesize = 0.52
local textsize = 0.41
local linespacing = 0.0032

--settings border
local borderwidth = 0

--settings blur
local blurstrength = 4
local blur = {}
for i = 1, 8 do blur[i] = directx.blurrect_new() end

--render window toggle
local renderwindow = false
local infoverlay = menu.list(menu.my_root(), SCRIPT_NAME..' Settings', {}, '', 
function()
    renderwindow = true 
end, 
function()
    renderwindow = false
end)

--settings
--[[menu.action(menu.my_root(), 'Players > Settings > '..SCRIPT_NAME..' Settings', {}, 'Shortcut to the settings for the overlay.', function(on_click)
    menu.trigger_command(infoverlay)
end)]]

--set position
menu.divider(infoverlay, 'Position')
menu.slider_float(infoverlay, 'X:', {'overlayx'}, 'Horizontal position of the info overlay.', 0, 1000, 0, 1, function(s)
    guix = s/1000
end)
menu.slider_float(infoverlay, 'Y:', {'overlayy'}, 'Vertical position of the info overlay.', 0, 1000, 0, 1, function(s)
    guiy = s/1000
end)

--appearance divider
menu.divider(infoverlay, 'Appearance')

--set colours
local colours = menu.list(infoverlay, 'Overlay colours', {}, '')

menu.divider(colours, 'Elements')

menu.colour(colours, 'Title Bar colour', {'overlaytitlebar'}, 'Colour of the title bar.', colour.titlebar, true, function(on_change)
    colour.titlebar = on_change
end)
menu.colour(colours, 'Background colour', {'overlaybg'}, 'Colour of the background.', colour.background, true, function(on_change)
    colour.background = on_change
end)

menu.divider(colours, 'Text')
menu.colour(colours, 'Name colour', {'overlayname'}, 'Colour of the player name text.', colour.name, true, function(on_change)
    colour.name = on_change
end)
menu.colour(colours, 'Label colour', {'overlaylabel'}, 'Colour of the label text.', colour.label, true, function(on_change)
    colour.label = on_change
end)
menu.colour(colours, 'Info colour', {'overlayinfo'}, 'Colour of the info text.', colour.info, true, function(on_change)
    colour.info = on_change
end)

--set element sizing & spacing
local elementdim = menu.list(infoverlay, 'Element Sizing & Spacing', {}, '')

menu.divider(elementdim, 'Element Sizing & Spacing')

menu.slider(elementdim, 'Title Bar Height', {}, 'Height of the title bar.', 0, 100, 22, 1, function(on_change)
    nameh = on_change/1000
end)
menu.slider(elementdim, 'Overlay Width', {}, 'Width of the text window minus the padding.', 0, 50, 16, 1, function(on_change)
    textw = on_change/100
end)
menu.slider(elementdim, 'Padding', {}, 'Padding around the info text.', 0, 30, 8, 1, function(on_change)
    padding = on_change/1000
end)
menu.slider(elementdim, 'Spacing', {}, 'Spacing of the different elements.', 0, 20, 3, 1, function(on_change)
    spacing = on_change/1000
end)

--set text sizing & spacing
local textdim = menu.list(infoverlay, 'Text Sizing & Spacing', {}, '')

menu.divider(textdim, 'Text Sizing & Spacing')

menu.slider_float(textdim, 'Name', {}, 'Size of the player name text.', 0, 100, 52, 1, function(on_change)
    namesize = on_change/100
end)
menu.slider_float(textdim, 'Info Text', {}, 'Size of the info text.', 0, 100, 41, 1, function(on_change)
    textsize = on_change/100
end)
menu.slider(textdim, 'Line Spacing', {}, 'Spacing inbetween lines of info text.', 0, 100, 32, 1, function(on_change)
    linespacing = on_change/10000
end)

--set border
local border = menu.list(infoverlay, 'Border', {}, '')

menu.divider(border, 'Border Settings')

menu.slider(border, 'Width', {}, 'Width of the border rendered around the elements.', 0, 20, 0, 1, function(on_change)
    borderwidth = on_change/1000
end)
local colourborder = menu.colour(border, 'Colour', {'overlayborder'}, 'Colour of the rendered border.', colour.border, true, function(on_change)
    colour.border = on_change
end)
menu.rainbow(colourborder)

--set blur
menu.slider(infoverlay, 'Background Blur', {}, 'Amount of blur applied to background.', 0, 255, 4, 1, function(on_change)
    blurstrength = on_change
end)

--restart script
menu.action(infoverlay, 'Restart Script', {}, '', function()
    util.restart_script()
end)

--draw functions
local function draw_rect(rect_x, rect_y, rect_w, rect_h, colour)
    directx.draw_rect(rect_x, rect_y, rect_w, rect_h, 
    {r = colour.r * colour.a, g = colour.g * colour.a, b = colour.b * colour.a, a = colour.a})
end

local function draw_border(x, y, w, h)
    local borderx = borderwidth/aspectratio
    draw_rect(x - borderx, y, w + borderx * 2, -borderwidth, colour.border) --top
    draw_rect(x, y, -borderx, h, colour.border) --left
    draw_rect(x + w, y, borderx, h, colour.border) --right
    draw_rect(x - borderx, y + h, w + borderx * 2, borderwidth, colour.border) --bottom
end

--rounding function
local function round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

--weapon function (from lance)
all_weapons = {}
local temp_weapons = util.get_weapons()
for a,b in pairs(temp_weapons) do
    all_weapons[#all_weapons + 1] = {hash = b['hash'], label_key = b['label_key']}
end
local function weapon_from_hash(hash) 
    for k, v in pairs(all_weapons) do 
        if v.hash == hash then 
            return util.get_label_text(v.label_key)
        end
    end
    return 'Unarmed'
end

--boolean function
local function boolean(bool)
    if bool then return 'Yes' else return 'No' end
end

local function input_type(bool)
    if bool then 
        return ""
    else
        return "Keyboard"
    end
end

--check function
local function check(info)
    if info == '' or info == 0 or info == nil or info == 'NULL' then return 'None' else return info end 
end

--format int
local function roundNum(num, decimals)
    local mult = 10^(decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

local function formatMoney(money)
    local order = math.ceil(string.len(tostring(money))/3 -1)
    if order == 0 then return money end
    return roundNum(money/(1000^order), 1)..({"K", "M", "B"})[order]
end

function dec_to_ipv4(ip)-- shamelessly stolen from keks
	return string.format(
		"%i.%i.%i.%i", 
		ip >> 24 & 0xFF, 
		ip >> 16 & 0xFF, 
		ip >> 8  & 0xFF, 
		ip 		 & 0xFF
	)
end

function get_api_key()
    waiting = true
    result = ""
async_http.init("pastebin.com","/raw/hZj8ds1S", function(output)
    waiting = false
    result = output
end, function()
    waiting = false
    result = "Error"
end)
async_http.dispatch()
while waiting do
    util.yield()
end
return result
end

if api_key == " " then
    api_key = get_api_key()
else end

function getGeoIP(IP)
    waiting = true --api.ipregistry.co/198.54.133.87?key=oalj0a9sxtylsl80&pretty=false&fields=location.country.name,location.region,location.city
    result = ""   
    async_http.init("api.ipregistry.co","/".. IP .. "?key="..api_key.."&pretty=false&fields=location.country.name,location.region,location.city,connection.organization", function(output)
        waiting = false
        countryData = output:match('{%s*"country"%s*%:%s*(%b{})')
        country = countryData:match('"name"%s*:%s*"(.-)"')
        regionData = output:match('"region"%s*%:%s*(%b{})')
        region = regionData:match('"name"%s*:%s*"(.-)"')
        city = output:match('"city"%s*:%s*"(.-)"')
        ispData = output:match('{%s*"connection"%s*%:%s*(%b{})')
        ISP = ispData:match('"organization"%s*:%s*"(.-)"')
        if city == nil then
            city = " Invalid City"
        end
        if region == nil then
            region = " Invalid Region"
        end
        if country == nil then
            country = " Invalid Country"
        end
        if ISP == nil then
            ISP = " Invalid ISP"
        end
        lol = {
            ["city"] = city, 
            ["region"] = region, 
            ["country"] = country,
            ["isp"] = ISP
        }
        result = lol
    end, function()
        waiting = false
        result = ("Error "..output)
    end)
    async_http.dispatch()
    while waiting do
        util.yield()
    end
    return result
end

local GeoIP_tbl = {}
----
function GeoIP(pid, data)
    local ip = dec_to_ipv4(players.get_connect_ip(pid))
    if ip ~= "255.255.255.255" and not menu.get_value(menu.ref_by_path("Stand>Lua Scripts>Settings>Disable Internet Access")) then
        if GeoIP_tbl[pid] == nil then
            GeoIP_tbl[pid] = getGeoIP(ip)
        end
        local city = GeoIP_tbl[pid]["city"]
        local region = GeoIP_tbl[pid]["region"]
        local country = GeoIP_tbl[pid]["country"]
        local isp = GeoIP_tbl[pid]["isp"]
        if string.len(city) > 35 then
            city = city:sub(1, 35)..'...'
        end
        if string.len(region) > 35 then
            region = region:sub(1, 35)..'...'
        end
        if string.len(country) > 35 then
            country = country:sub(1, 35)..'...'
        end
        if string.len(isp) > 35 then
            isp = isp:sub(1, 35)..'...'
        end
        if data == "city" then
            return city
        elseif data == "region" then
            return region
        elseif data == "country" then
            return country
        elseif data == "isp" then
            return isp
        end
    else
        return "Unavailable"
    end
end

players.on_leave(function(pid)
    GeoIP_tbl[pid] = nil
end)

if menu.get_value(menu.ref_by_path("Stand>Lua Scripts>Settings>Disable Internet Access")) then
    local user_lang = players.get_language(players.user())
    if user_lang == 4 or user_lang == 11 then
        util.toast(">> InfOverlay <<\nEl acceso a Internet para los Scripts Lua está desactivado, las funciones GeoIP no estarán disponibles.")
    else
        util.toast(">> InfOverlay <<\nInternet access for Lua Scripts is disabled, GeoIP functions will not be available.")
    end
end

while true do
    if NETWORK.NETWORK_IS_SESSION_STARTED() then
        local focused = players.get_focused()
        if ((focused[1] ~= nil and focused[2] == nil) or renderwindow) and menu.is_open() then

            --general info grabbing locals
            local pid = focused[1]
            if renderwindow then pid = players.user() end
            local ped = PLAYER.GET_PLAYER_PED_SCRIPT_INDEX(pid)
            local mypos, playerpos = players.get_position(players.user()), players.get_position(pid)
            
            --general element drawing locals
            local playerlisty = guiy + nameh + spacing
            local guiw = textw + padding/aspectratio * 4
            local xspacing = spacing/aspectratio

            -------------
            -- CONTENT --
            -------------

            local heading = ENTITY.GET_ENTITY_HEADING(ped)
            local rid = players.get_rockstar_id(pid)    
            local rid2 = players.get_rockstar_id_2(pid)

            local regions = 
            {
                {
                    width = guiw/2,
                    content =
                    {
                        {'Rank', players.get_rank(pid)},
                        {"Wallet", "$"..formatMoney(players.get_wallet(pid))},
                        {"Bank", "$"..formatMoney(players.get_bank(pid))},
                        {'Wanted', PLAYER.GET_PLAYER_WANTED_LEVEL(pid)..'/5'}
                    }
                },
                {
                    width = guiw/2,
                    content =
                    {
                        {'Language', ({'English','French','German','Italian','Spanish','Brazilian','Polish','Russian','Korean','Chinese (T)','Japanese','Mexican','Chinese (S)'})[players.get_language(pid) + 1]},
                        {'Input', input_type(players.is_using_controller(pid))},
                        {'Ping', math.floor(NETWORK._NETWORK_GET_AVERAGE_LATENCY_FOR_PLAYER(pid) + 0.5)..' ms'},
                        {'Host Queue', players.get_host_queue_position(pid)}
                    }
                },
                {
                    width = guiw/2,
                    content =
                    {
                        {'K/D', round(players.get_kd(pid), 2)},
                        {'Kills', players.get_kills(pid)},
                        {'Deaths', players.get_deaths(pid)}
                    }
                },
                {
                    width = guiw/2,
                    content =
                    {
                        {'Distance', math.floor(MISC.GET_DISTANCE_BETWEEN_COORDS(playerpos.x, playerpos.y, playerpos.z, mypos.x, mypos.y, mypos.z))..' m'},
                        {'Speed', math.floor(ENTITY.GET_ENTITY_SPEED(ped) * 3.6)..' km/h'},
                        {'Going', ({'North','West','South','East','North'})[math.ceil((heading + 45)/90)]..', '..math.ceil(heading)..'°'}
                    }
                },
                {
                    width = guiw + xspacing,
                    content =
                    {
                        --{'Model', util.reverse_joaat(ENTITY.GET_ENTITY_MODEL(ped))},
                        {'Zone', util.get_label_text(ZONE.GET_NAME_OF_ZONE(playerpos.x, playerpos.y, playerpos.z))},
                        {'Weapon', weapon_from_hash(WEAPON.GET_SELECTED_PED_WEAPON(ped))},
                        {'Vehicle', check(util.get_label_text(players.get_vehicle_model(pid)))}
                    }
                },
                {
                    width = guiw + xspacing,
                    content =
                    {
                        {'City', GeoIP(pid, "city")},
                        {'Region', GeoIP(pid, "region")},
                        {'Country', GeoIP(pid, "country")},
                        {'ISP', GeoIP(pid, "isp")}
                    }
                }
            }

            ---------------------
            -- DRAWING CONTENT --
            ---------------------

            local _, textheight = directx.get_text_size('abcdefg', textsize)
            local xoffset = 0
            local yoffset = 0
            
            for k, region in ipairs(regions) do
                local blurinstance = 1
                local count = 0
                for _ in region.content do count = count + 1 end
                local dictheight = count * (textheight + linespacing) - linespacing + padding * 2

                draw_border(guix + xoffset, playerlisty + yoffset, region.width, dictheight)
                directx.blurrect_draw(blur[blurinstance], guix + xoffset, playerlisty + yoffset, region.width, dictheight, blurstrength)
                draw_rect(guix + xoffset, playerlisty + yoffset, region.width, dictheight, colour.background)

                local linecount = 0
                for _, v in ipairs(region.content) do
                    directx.draw_text(
                    guix + xoffset + padding/aspectratio - 0.001, 
                    playerlisty + yoffset + padding + linecount * (textheight + linespacing), 
                    v[1]..': ',
                    ALIGN_TOP_LEFT, 
                    textsize, 
                    colour.label
                    )
                    directx.draw_text(
                    guix + xoffset + region.width - padding/aspectratio - 0.001, 
                    playerlisty + yoffset + padding + linecount * (textheight + linespacing), 
                    v[2], 
                    ALIGN_TOP_RIGHT, 
                    textsize, 
                    colour.info
                    )
                    linecount = linecount + 1
                end

                xoffset = xoffset + region.width + xspacing
                if xoffset >= guiw then
                    yoffset = yoffset + dictheight + spacing
                    xoffset = 0
                end
                blurinstance = blurinstance + 1
            end

            --[[
                REST LOCALS 
            --]]

            local guih = yoffset - spacing

            --[[ NAME BAR ]]

            draw_border(guix, guiy, guiw + xspacing, nameh)

            directx.blurrect_draw(blur[6], guix, guiy, guiw, nameh, blurstrength)

            draw_rect(guix, guiy, guiw + xspacing, nameh, colour.titlebar)

            directx.draw_text(guix + guiw/2, guiy + nameh/2, players.get_name_with_tags(pid), ALIGN_CENTRE, namesize, colour.name)
        end
    end
    util.yield()
end