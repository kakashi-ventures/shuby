# frozen_string_literal: true

namespace :demo do
  desc "Create demo accounts for team testing (idempotent, safe to re-run)"
  task setup: :environment do
    if Rails.env.production?
      puts "\n⚠️  PRODUCTION — This will create 2 demo accounts with test data."
      puts "  • maria@demo.shuby / testtest (Famiglia Rossi — fully populated)"
      puts "  • luca@demo.shuby  / testtest (Famiglia Bianchi — premium, lighter data)"
      print "\nType YES to continue: "
      abort "Cancelled." unless $stdin.gets&.strip == "YES"
    end

    ActiveRecord::Base.transaction do
      create_famiglia_rossi
      create_famiglia_bianchi
      print_summary
    end
  end

  desc "Remove demo accounts and all their data"
  task teardown: :environment do
    if Rails.env.production?
      puts "\n⚠️  PRODUCTION — This will DELETE all demo accounts (@demo.shuby)."
      print "Type YES to continue: "
      abort "Cancelled." unless $stdin.gets&.strip == "YES"
    end

    users = User.where("email LIKE ?", "%@demo.shuby")
    if users.none?
      puts "No demo accounts found."
    else
      users.find_each do |user|
        puts "Destroying #{user.email} and all associated data..."
        user.destroy!
      end
      puts "Done. All demo accounts removed."
    end
  end
end

# ---------------------------------------------------------------------------
# Famiglia Rossi — fully populated account
# ---------------------------------------------------------------------------
def create_famiglia_rossi
  puts "\n--- Famiglia Rossi ---"

  maria = find_or_create_demo_user!(
    email: "maria@demo.shuby",
    first_name: "Maria",
    last_name: "Rossi",
    password: "testtest"
  )
  account = maria.personal_account
  account.update!(name: "Famiglia Rossi")

  # AccountUser relationship
  account_user = AccountUser.find_by!(account: account, user: maria)
  account_user.update!(relationship_to_child: :mom)

  # Family profile
  create_family_profile!(account,
    country: "Italia",
    nationality: "Italiana",
    mother_tongue: "Italiano",
    family_structure: :two_parents,
    number_of_children: 3,
    languages_spoken_at_home: 2,
    primary_caregivers: %w[parents grandparents])

  # --- Children ---
  sofia = find_or_create_child!(account, name: "Sofia", birth_date: 3.months.ago.to_date, sex: :female)
  marco = find_or_create_child!(account, name: "Marco", birth_date: 12.months.ago.to_date, sex: :male)
  giulia = find_or_create_child!(account, name: "Giulia", birth_date: 24.months.ago.to_date, sex: :female,
    gestational_weeks: 34, gestational_days: 0)

  # --- Measurements ---
  create_sofia_measurements(sofia)
  create_marco_measurements(marco)
  create_giulia_measurements(giulia)

  # --- Questionnaires ---
  create_rossi_questionnaires(sofia, marco, giulia)

  # --- Shuby Chats ---
  create_rossi_chats(maria, account, sofia, marco)

  # --- Archive Favorites ---
  create_archive_favorites(maria, count: 3)

  # --- Pediatrician Questions ---
  create_pediatrician_questions(sofia, [
    "Sofia non sembra reagire ai rumori forti. Dovremmo fare un controllo dell'udito?",
    "Quanto tempo di tummy time al giorno è raccomandato a questa età?"
  ])
  create_pediatrician_questions(marco, [
    "Marco non ha ancora iniziato a camminare a 12 mesi. È normale?"
  ])

  puts "  ✓ Maria Rossi with Sofia, Marco, Giulia"
end

# ---------------------------------------------------------------------------
# Famiglia Bianchi — premium, lighter data
# ---------------------------------------------------------------------------
def create_famiglia_bianchi
  puts "\n--- Famiglia Bianchi ---"

  luca = find_or_create_demo_user!(
    email: "luca@demo.shuby",
    first_name: "Luca",
    last_name: "Bianchi",
    password: "testtest"
  )
  account = luca.personal_account
  account.update!(name: "Famiglia Bianchi")

  # AccountUser relationship
  account_user = AccountUser.find_by!(account: account, user: luca)
  account_user.update!(relationship_to_child: :dad)

  # Family profile
  create_family_profile!(account,
    country: "Italia",
    nationality: "Italiana",
    mother_tongue: "Italiano",
    family_structure: :single_parent,
    number_of_children: 1,
    languages_spoken_at_home: 1,
    primary_caregivers: %w[parents])

  # Premium subscription via fake_processor
  setup_premium_subscription(account)

  # Child
  lorenzo = find_or_create_child!(account, name: "Lorenzo", birth_date: 6.months.ago.to_date, sex: :male)

  # Measurements (birth → 6 months)
  create_lorenzo_measurements(lorenzo)

  # One completed questionnaire
  create_bianchi_questionnaires(lorenzo)

  # One chat
  create_bianchi_chat(luca, account, lorenzo)

  puts "  ✓ Luca Bianchi (premium) with Lorenzo"
end

# ===========================================================================
# Helper methods
# ===========================================================================

def find_or_create_demo_user!(email:, first_name:, last_name:, password:)
  user = User.find_or_initialize_by(email: email)
  user.assign_attributes(
    first_name: first_name,
    last_name: last_name,
    password: password,
    password_confirmation: password,
    terms_of_service: true
  )
  user.save!
  user.update_columns(
    confirmed_at: Time.current,
    onboarding_step: 1, # :complete
    onboarding_completed_at: Time.current
  )
  user
end

def create_family_profile!(account, **attrs)
  profile = account.family_profile || account.build_family_profile
  profile.assign_attributes(attrs)
  profile.save!
  profile
end

def find_or_create_child!(account, name:, birth_date:, sex:, gestational_weeks: nil, gestational_days: nil)
  child = account.children.find_or_initialize_by(name: name)
  child.assign_attributes(birth_date: birth_date, sex: sex,
    gestational_weeks: gestational_weeks, gestational_days: gestational_days)
  child.save!
  child
end

def create_measurement!(child, type:, value:, measured_at:)
  m = child.measurements.find_or_initialize_by(measurement_type: type, measured_at: measured_at)
  m.assign_attributes(value: value)
  m.save!
end

def setup_premium_subscription(account)
  # Create or find a premium plan for the fake processor
  plan = Plan.find_or_initialize_by(name: "Premium")
  plan.assign_attributes(
    amount: 999,
    currency: "eur",
    interval: "month",
    trial_period_days: 0,
    fake_processor_id: "premium",
    hidden: false
  )
  plan.save!

  pay_customer = account.set_payment_processor(:fake_processor, allow_fake: true)
  # Only subscribe if not already subscribed
  unless pay_customer.subscribed?
    pay_customer.subscribe(plan: "premium")
  end
end

# ---------------------------------------------------------------------------
# Measurement data — realistic WHO-range values
# ---------------------------------------------------------------------------

def create_sofia_measurements(child)
  # Sofia: ~3 months female — birth to now
  birth = child.birth_date
  data = [
    {age_days: 0, w: 3200, h: 49.0, hc: 33.5},
    {age_days: 14, w: 3400, h: 50.5, hc: 34.5},
    {age_days: 30, w: 4100, h: 53.0, hc: 36.0},
    {age_days: 45, w: 4700, h: 55.5, hc: 37.5},
    {age_days: 60, w: 5300, h: 57.5, hc: 38.5},
    {age_days: 75, w: 5800, h: 59.5, hc: 39.5},
    {age_days: 90, w: 6200, h: 61.0, hc: 40.0}
  ]
  create_measurement_series(child, birth, data)
end

def create_marco_measurements(child)
  # Marco: ~12 months male — birth to now
  birth = child.birth_date
  data = [
    {age_days: 0, w: 3400, h: 50.0, hc: 34.0},
    {age_days: 30, w: 4200, h: 54.0, hc: 37.0},
    {age_days: 60, w: 5400, h: 58.0, hc: 39.5},
    {age_days: 90, w: 6300, h: 61.5, hc: 41.0},
    {age_days: 120, w: 7000, h: 64.0, hc: 42.5},
    {age_days: 180, w: 7800, h: 67.5, hc: 43.5},
    {age_days: 240, w: 8500, h: 71.0, hc: 44.5},
    {age_days: 300, w: 9200, h: 73.5, hc: 45.5},
    {age_days: 360, w: 9800, h: 75.0, hc: 46.0}
  ]
  create_measurement_series(child, birth, data)
end

def create_giulia_measurements(child)
  # Giulia: ~24 months female, premature (34 weeks) — birth to now
  birth = child.birth_date
  data = [
    {age_days: 0, w: 2100, h: 44.0, hc: 31.0},
    {age_days: 30, w: 3000, h: 48.0, hc: 33.5},
    {age_days: 90, w: 4800, h: 55.0, hc: 37.0},
    {age_days: 150, w: 6200, h: 61.0, hc: 40.0},
    {age_days: 210, w: 7200, h: 65.0, hc: 42.0},
    {age_days: 300, w: 8500, h: 71.0, hc: 44.0},
    {age_days: 420, w: 9800, h: 78.0, hc: 46.0},
    {age_days: 540, w: 10800, h: 82.0, hc: 47.0},
    {age_days: 660, w: 11500, h: 85.0, hc: 48.0},
    {age_days: 720, w: 12000, h: 86.5, hc: 48.5}
  ]
  create_measurement_series(child, birth, data)
end

def create_lorenzo_measurements(child)
  # Lorenzo: ~6 months male — birth to now
  birth = child.birth_date
  data = [
    {age_days: 0, w: 3500, h: 51.0, hc: 35.0},
    {age_days: 30, w: 4400, h: 55.0, hc: 37.5},
    {age_days: 90, w: 6200, h: 61.0, hc: 40.5},
    {age_days: 150, w: 7600, h: 66.0, hc: 43.0},
    {age_days: 180, w: 8100, h: 68.0, hc: 43.5}
  ]
  create_measurement_series(child, birth, data)
end

def create_measurement_series(child, birth, data)
  data.each do |row|
    measured_at = birth + row[:age_days].days
    # Skip future measurements
    next if measured_at > Date.current

    create_measurement!(child, type: :weight, value: row[:w], measured_at: measured_at)
    create_measurement!(child, type: :height, value: row[:h], measured_at: measured_at)
    create_measurement!(child, type: :head_circumference, value: row[:hc], measured_at: measured_at)
  end
end

# ---------------------------------------------------------------------------
# Questionnaire sessions
# ---------------------------------------------------------------------------

def create_rossi_questionnaires(sofia, marco, giulia)
  # Sofia (~3mo): 2 completed in different areas + 1 in-progress
  create_completed_session(sofia, area_position: 1, age_month: 2)
  create_completed_session(sofia, area_position: 2, age_month: 2)
  create_in_progress_session(sofia, area_position: 3, age_month: 3)

  # Marco (~12mo): 3 completed + 1 in-progress
  create_completed_session(marco, area_position: 1, age_month: 11)
  create_completed_session(marco, area_position: 2, age_month: 11)
  create_completed_session(marco, area_position: 4, age_month: 11)
  create_in_progress_session(marco, area_position: 3, age_month: 12)

  # Giulia (~24mo, corrected age ~22.6mo): 2 completed
  create_completed_session(giulia, area_position: 1, age_month: 23)
  create_completed_session(giulia, area_position: 2, age_month: 23)
end

def create_bianchi_questionnaires(lorenzo)
  # Lorenzo (~6mo): 1 completed session
  create_completed_session(lorenzo, area_position: 1, age_month: 5)
end

def create_completed_session(child, area_position:, age_month:)
  questionnaire = find_questionnaire(area_position: area_position, age_month: age_month)
  return unless questionnaire

  session = child.questionnaire_sessions.find_or_initialize_by(age_band_questionnaire: questionnaire)
  if session.new_record?
    session.save!
    create_responses_for_session(session, complete: true)
  end
end

def create_in_progress_session(child, area_position:, age_month:)
  questionnaire = find_questionnaire(area_position: area_position, age_month: age_month)
  return unless questionnaire

  session = child.questionnaire_sessions.find_or_initialize_by(age_band_questionnaire: questionnaire)
  if session.new_record?
    session.save!
    create_responses_for_session(session, complete: false)
  end
end

def find_questionnaire(area_position:, age_month:)
  area = DevelopmentArea.find_by(position: area_position)
  return nil unless area

  AgeBandQuestionnaire
    .where(development_area: area)
    .where("min_age_months <= ? AND max_age_months > ?", age_month, age_month)
    .first
end

def create_responses_for_session(session, complete:)
  questions = session.age_band_questionnaire.questions.active.ordered
  return if questions.empty?

  # For complete sessions: answer all questions
  # For in-progress: answer ~half
  questions_to_answer = complete ? questions : questions.first(questions.size / 2)

  answers = [:si, :si, :si, :no, :incerto] # Weighted toward positive
  questions_to_answer.each_with_index do |question, i|
    session.question_responses.find_or_create_by!(question: question) do |r|
      r.answer = answers[i % answers.size]
    end
  end

  # The after_save callback on QuestionResponse auto-updates session status.
  # For completed sessions, explicitly mark completed if all questions answered.
  if complete && session.question_responses.count >= questions.size
    session.update_columns(status: 2, completed_at: 1.week.ago) # 2 = :completed
  end
end

# ---------------------------------------------------------------------------
# Chat conversations
# ---------------------------------------------------------------------------

def create_rossi_chats(user, account, sofia, marco)
  # Chat 1: About Sofia's sleep
  chat1 = find_or_create_chat!(user, account, sofia, title: "Sonno di Sofia")
  seed_chat_messages(chat1, [
    {role: "user", content: "Sofia ha 3 mesi e si sveglia ancora ogni 2 ore di notte. È normale?"},
    {role: "assistant", content: "Sì, è assolutamente normale! A 3 mesi i neonati hanno ancora bisogno di poppate frequenti e i loro cicli di sonno sono molto brevi (circa 50-60 minuti). La maggior parte dei bambini a questa età si sveglia 2-3 volte a notte. Verso i 4-6 mesi molti bambini iniziano a dormire per periodi più lunghi. Alcuni consigli: mantieni una routine serale costante, distingui il giorno dalla notte con luci e rumori diversi, e metti Sofia nella culla quando è sonnolenta ma ancora sveglia."},
    {role: "user", content: "Grazie! E per il tummy time, quanto tempo dovrebbe fare al giorno?"},
    {role: "assistant", content: "A 3 mesi, l'ideale è arrivare a circa 20-30 minuti al giorno di tummy time, distribuiti in sessioni brevi di 3-5 minuti. Non deve essere tutto in una volta! Puoi farlo dopo ogni cambio pannolino, per esempio. Il tummy time è fondamentale per rafforzare i muscoli del collo, delle spalle e della schiena, che prepareranno Sofia per rotolarsi, gattonare e poi sedersi. Se Sofia non ama stare a pancia in giù, prova a metterti di fronte a lei con un giocattolo colorato o uno specchio per stimolarla."}
  ])

  # Chat 2: About Marco's feeding
  chat2 = find_or_create_chat!(user, account, marco, title: "Alimentazione di Marco")
  seed_chat_messages(chat2, [
    {role: "user", content: "Marco ha quasi 12 mesi. Possiamo iniziare con il latte vaccino?"},
    {role: "assistant", content: "A 12 mesi compiuti puoi iniziare a introdurre il latte vaccino intero (non scremato o parzialmente scremato). Prima dei 12 mesi non è consigliato perché contiene troppe proteine e minerali per i reni immaturi del bambino, e non fornisce abbastanza ferro e vitamina E. Inizia gradualmente: offrigli piccole quantità nel bicchierino durante i pasti. La quantità consigliata è di circa 200-400 ml al giorno, senza superare i 500 ml per non ridurre l'appetito per altri alimenti nutrienti. Se Marco è allattato al seno, puoi continuare tranquillamente l'allattamento insieme al latte vaccino."},
    {role: "user", content: "E quali alimenti dovrebbe mangiare regolarmente a questa età?"},
    {role: "assistant", content: "A 12 mesi Marco dovrebbe avere un'alimentazione varia e bilanciata. Ecco cosa includere:\n\n• **Carboidrati**: pasta, riso, pane, patate, cereali\n• **Proteine**: carne, pesce (2-3 volte/settimana), uova, legumi, formaggi\n• **Frutta e verdura**: almeno 5 porzioni al giorno tra frutta e verdura di stagione\n• **Grassi buoni**: olio extravergine d'oliva (un cucchiaino a pasto)\n\nA questa età può mangiare quasi tutto quello che mangiate voi, purché sia tagliato in pezzi piccoli e sicuri. Evita: miele (fino a 12 mesi compiuti), frutta secca intera (rischio soffocamento), sale e zucchero aggiunti."}
  ])
end

def create_bianchi_chat(user, account, lorenzo)
  chat = find_or_create_chat!(user, account, lorenzo, title: "Sviluppo di Lorenzo")
  seed_chat_messages(chat, [
    {role: "user", content: "Lorenzo ha 6 mesi e non si gira ancora dalla pancia alla schiena. Devo preoccuparmi?"},
    {role: "assistant", content: "Non necessariamente! Ogni bambino ha i propri tempi di sviluppo. La maggior parte dei bambini impara a girarsi tra i 4 e i 7 mesi, quindi Lorenzo è ancora perfettamente nella norma. Alcuni bambini saltano completamente questa tappa e passano direttamente a sedersi o gattonare. Per incoraggiarlo, puoi: mettere un giocattolo appena fuori dalla sua portata durante il tummy time, aiutarlo delicatamente nel movimento di rotazione, e assicurarti che abbia abbastanza tempo libero sul pavimento (non sempre nel seggiolino o nel passeggino). Se a 8 mesi non mostra ancora nessun tentativo di girarsi, parlane con il pediatra alla prossima visita."},
    {role: "user", content: "Ok, grazie. Quante pappe al giorno dovrebbe fare ora?"},
    {role: "assistant", content: "A 6 mesi, se avete appena iniziato lo svezzamento, è normale cominciare con 1-2 pappe al giorno, oltre al latte materno o formulato che resta l'alimento principale. Ecco una guida:\n\n• **Inizio (prime 2-4 settimane)**: 1 pappa al giorno, preferibilmente a pranzo\n• **Dopo il primo mese di svezzamento**: 2 pappe (pranzo e cena)\n• **Le quantità**: inizia con pochi cucchiaini e lascia che Lorenzo regoli da solo quanto mangiare\n\nIl latte (materno o formula) dovrebbe ancora coprire circa il 70% del fabbisogno calorico a questa età. Non forzare mai il bambino a finire la pappa — è importante che sviluppi un rapporto sano con il cibo."}
  ])
end

def find_or_create_chat!(user, account, child, title:)
  chat = user.shuby_chats.find_or_initialize_by(account: account, title: title)
  if chat.new_record?
    chat.child = child
    chat.model = ShubyAssistantService::DEFAULT_MODEL
    chat.save!
  end
  chat
end

def seed_chat_messages(chat, messages)
  return if chat.messages.any? # Don't duplicate messages on re-run

  messages.each do |msg|
    chat.messages.create!(
      role: msg[:role],
      content: msg[:content],
      model_id: ((msg[:role] == "assistant") ? ShubyAssistantService::DEFAULT_MODEL : nil)
    )
  end
end

# ---------------------------------------------------------------------------
# Archive favorites
# ---------------------------------------------------------------------------

def create_archive_favorites(user, count:)
  published = ArchiveContent.where(published: true).order(:position).limit(count)
  published.each do |content|
    ArchiveFavorite.find_or_create_by!(user: user, archive_content: content)
  end
end

# ---------------------------------------------------------------------------
# Pediatrician questions
# ---------------------------------------------------------------------------

def create_pediatrician_questions(child, bodies)
  bodies.each_with_index do |body, i|
    child.pediatrician_questions.find_or_create_by!(body: body) do |q|
      q.position = i
    end
  end
end

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

def print_summary
  puts "\n" + "=" * 60
  puts "Demo accounts ready!"
  puts "=" * 60
  puts
  puts "  maria@demo.shuby / testtest"
  puts "    → Famiglia Rossi (3 children, full data)"
  puts
  puts "  luca@demo.shuby  / testtest"
  puts "    → Famiglia Bianchi (1 child, premium subscriber)"
  puts
  puts "=" * 60
end
