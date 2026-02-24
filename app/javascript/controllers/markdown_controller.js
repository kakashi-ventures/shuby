import { Controller } from "@hotwired/stimulus"

// Controller for rendering Markdown content
// Converts markdown to HTML with basic formatting support
export default class extends Controller {
    static targets = ["output"]
    static values = { content: String }

    connect() {
        this.render()
    }

    contentValueChanged() {
        this.render()
    }

    render() {
        if (!this.hasOutputTarget || !this.contentValue) return

        // Basic markdown rendering
        let html = this.contentValue

        // Escape HTML first
        html = this.escapeHtml(html)

        // Headers
        html = html.replace(/^### (.*$)/gim, '<h3 class="text-lg font-semibold mt-4 mb-2">$1</h3>')
        html = html.replace(/^## (.*$)/gim, '<h2 class="text-xl font-semibold mt-4 mb-2">$1</h2>')
        html = html.replace(/^# (.*$)/gim, '<h1 class="text-2xl font-bold mt-4 mb-2">$1</h1>')

        // Bold and italic
        html = html.replace(/\*\*\*(.+?)\*\*\*/g, '<strong><em>$1</em></strong>')
        html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
        html = html.replace(/\*(.+?)\*/g, '<em>$1</em>')

        // Markdown links [text](url)
        html = html.replace(/\[([^\]]+)\]\(([^)]+)\)/g,
            '<a href="$2" class="text-primary-600 dark:text-primary-400 underline hover:text-primary-800 dark:hover:text-primary-300" data-turbo-frame="_top">$1</a>')

        // Blockquotes
        html = html.replace(/^> (.*)$/gim, '<blockquote class="pl-4 border-l-4 border-gray-300 dark:border-gray-600 italic my-2">$1</blockquote>')

        // Unordered lists
        html = html.replace(/^\* (.*)$/gim, '<li class="ml-4">$1</li>')
        html = html.replace(/^- (.*)$/gim, '<li class="ml-4">$1</li>')
        html = html.replace(/(<li.*<\/li>\n?)+/g, '<ul class="list-disc list-inside my-2">$&</ul>')

        // Ordered lists
        html = html.replace(/^\d+\. (.*)$/gim, '<li class="ml-4">$1</li>')

        // Code blocks
        html = html.replace(/```(\w*)\n([\s\S]*?)```/g, '<pre class="bg-gray-100 dark:bg-gray-700 p-3 rounded-lg my-2 overflow-x-auto"><code>$2</code></pre>')

        // Inline code
        html = html.replace(/`([^`]+)`/g, '<code class="bg-gray-100 dark:bg-gray-700 px-1 py-0.5 rounded text-sm">$1</code>')

        // Tables (basic support)
        html = this.renderTables(html)

        // Line breaks
        html = html.replace(/\n\n/g, '</p><p class="my-2">')
        html = html.replace(/\n/g, '<br>')

        // Wrap in paragraph
        if (!html.startsWith('<')) {
            html = '<p class="my-2">' + html + '</p>'
        }

        this.outputTarget.innerHTML = html
    }

    renderTables(html) {
        // Simple table rendering
        const tableRegex = /\|(.+)\|\n\|[-:| ]+\|\n((?:\|.+\|\n?)+)/g

        return html.replace(tableRegex, (match, header, body) => {
            const headers = header.split('|').filter(h => h.trim())
            const rows = body.trim().split('\n').map(row =>
                row.split('|').filter(cell => cell.trim())
            )

            let table = '<div class="overflow-x-auto my-4"><table class="min-w-full divide-y divide-gray-200 dark:divide-gray-700">'
            table += '<thead class="bg-gray-50 dark:bg-gray-800"><tr>'
            headers.forEach(h => {
                table += `<th class="px-3 py-2 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase">${h.trim()}</th>`
            })
            table += '</tr></thead><tbody class="divide-y divide-gray-200 dark:divide-gray-700">'

            rows.forEach(row => {
                table += '<tr>'
                row.forEach(cell => {
                    table += `<td class="px-3 py-2 text-sm">${cell.trim()}</td>`
                })
                table += '</tr>'
            })

            table += '</tbody></table></div>'
            return table
        })
    }

    escapeHtml(text) {
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;'
        }
        return text.replace(/[&<>]/g, m => map[m])
    }
}
