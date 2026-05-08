class ArchiveContentResource < Madmin::Resource
  menu parent: "Contenuti Shuby", label: "📚 Archivio Contenuti", position: 1

  # Scopes for filtering
  scope :published
  scope :draft
  scope :articles
  scope :tips
  scope :activities

  # Attributes — order matters for index columns
  attribute :id, form: false, index: false
  attribute :title, label: "Titolo"
  attribute :content_type, :select, index: true,
    collection: ArchiveContent.content_types.keys,
    label: "Tipo",
    description: "Articolo = approfondimento, Tip = consiglio rapido o libro, Attività = esercizio pratico"
  attribute :category, :select, index: true,
    collection: ArchiveContent::CATEGORIES_BY_TYPE.values.flatten.uniq.sort,
    label: "Categoria",
    description: "Articoli: Abilità motorie, Attaccamento, Benessere familiare, Comunicazione, Neurosviluppo, Sonno · Consigli: Giochi, Lettura · Attività: nessuna categoria"
  attribute :published, :boolean, index: true,
    label: "Pubblicato",
    description: "Solo i contenuti pubblicati appaiono nell'app"
  attribute :specialist, :boolean, index: true,
    label: "Specialistico",
    description: "Articoli specialistici (es. ritardo linguaggio, regressioni, segnali atipici) sono visibili solo agli utenti Premium"
  attribute :position, index: true,
    label: "Pos.",
    description: "Ordine di visualizzazione (numero più basso = prima)"

  # Fields visible only in form (not in index)
  attribute :description, index: false,
    label: "Descrizione breve",
    description: "Appare nell'anteprima della card nell'archivio"
  attribute :body, :rich_text, index: false,
    label: "Testo completo",
    description: "Contenuto principale dell'articolo. Usa la toolbar per formattare il testo."
  attribute :min_age_months, index: false,
    label: "Età minima (mesi)",
    description: "Da quale mese è rilevante (0-36)"
  attribute :max_age_months, index: false,
    label: "Età massima (mesi)",
    description: "Fino a quale mese è rilevante (0-36)"

  # Tip fields (books)
  attribute :author, index: false,
    label: "Autore",
    description: "Autore del libro consigliato"
  attribute :illustrator, index: false,
    label: "Illustratore"
  attribute :publisher, index: false,
    label: "Editore"
  attribute :publication_year, index: false,
    label: "Anno di pubblicazione"
  attribute :isbn, index: false,
    label: "ISBN"

  # Activity fields
  attribute :duration_minutes, index: false,
    label: "Durata (minuti)",
    description: "Durata stimata dell'attività"
  attribute :materials, index: false,
    label: "Materiali necessari",
    description: "Elenco dei materiali necessari per l'attività"
  attribute :benefits_text, :text, index: false, form: true,
    label: "Benefici",
    description: "Un beneficio per riga (es. 'Stimola la circolazione e la percezione corporea.'). Appare nella pagina dettaglio attività con un elenco a cuoricini fucsia. Le righe vuote vengono ignorate."

  # Tip recommendations (Figma 532:25861 game / 532:26226 book "Perché è consigliato").
  attribute :recommendations_text, :text, index: false, form: true,
    label: "Raccomandazioni",
    description: "Una raccomandazione per riga (es. 'Stimola la coordinazione visiva.'). Solo per consigli (giochi e libri) — appare nella pagina dettaglio con un elenco a pallini blu. Usa **testo** per le frasi in grassetto. Le righe vuote vengono ignorate."

  # Publishing (form only)
  attribute :published_at, index: false,
    label: "Data pubblicazione"

  # Attachment
  attribute :cover_image, index: false,
    label: "Immagine di copertina",
    description: "Se non caricata, verrà usata un'illustrazione predefinita"

  # Timestamps
  attribute :created_at, form: false, index: false
  attribute :updated_at, form: false, index: false

  def self.display_name(record)
    record.title
  end

  def self.default_sort_column
    "position"
  end

  def self.default_sort_direction
    "asc"
  end

  member_action do
    link_to "View", main_app.archive_path(@record.slug), class: "btn btn-secondary"
  end
end
