local target_classes = {
    "gesis-card-rust",
    "gesis-card-orange",
    "gesis-card-turquoise",
    "gesis-card-berry"
}

-- Function to check if a div has any of the target classes
local function has_target_class(classes)
    for _, class in ipairs(target_classes) do
        if classes:includes(class) then
            return true
        end
    end
    return false
end

function Div(el)
    if has_target_class(el.classes) then
        for i, content in ipairs(el.content) do
            if content.t == "Para" then
                el.content[i] = pandoc.Plain(
                    { pandoc.RawInline('html', '<p class="card-header">') } ..
                    content.content ..
                    { pandoc.RawInline('html', '</p>') }
                )
                break
            end
        end
    end

    if el.classes:includes("gesis-collapse") then
        local first_para = nil
        local remaining_content = {}

        for i, content in ipairs(el.content) do
            if content.t == "Para" and not first_para then
                first_para = content
            else
                table.insert(remaining_content, content)
            end
        end

        local collapse_id = "collapse-" .. pandoc.utils.sha1(pandoc.write(pandoc.Pandoc({ el }), "html"))

        local button_html = pandoc.RawBlock(
            "html",
            '<button class="btn collapse-button" type="button" data-bs-toggle="collapse" data-bs-target="#' ..
            collapse_id .. '" aria-expanded="false" aria-controls="' .. collapse_id .. '">' ..
            pandoc.utils.stringify(first_para) ..
            '</button>'
        )

        -- Create the collapsible div with the remaining content
        local collapse_content = pandoc.Div(
            remaining_content,
            { id = collapse_id, class = "collapse collapse-bg" }
        )

        -- Return both the button and the collapsible content in sequence
        return { button_html, collapse_content }
    end

    return el
end
