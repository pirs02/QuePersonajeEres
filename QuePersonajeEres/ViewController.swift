//
//  ViewController.swift
//  QuePersonajeEres
//
//  Implementa el planteamiento de "¿Qué personaje eres?":
//  a) 5 preguntas determinan el personaje del usuario.
//  b) El usuario elige una opción de una lista en pantalla.
//  c) Solo puede elegir una respuesta por pregunta y no puede cambiarla al avanzar.
//  d) Al responder la pregunta 5, se muestra el personaje resultante con su descripción.
//

import UIKit

// Estructura que representa una pregunta y sus opciones.
// Cada opción es una tupla (texto mostrado, personaje al que suma punto).
struct Question {
    let text: String
    let options: [(text: String, character: String)]
}

class ViewController: UIViewController {

    // MARK: - Colección: Array con las 5 preguntas del cuestionario
    let questions: [Question] = [
        Question(text: "¿Cómo resuelves un problema difícil?",
                  options: [("Con lógica y paciencia", "Estratega"),
                            ("Con valentía y acción directa", "Héroe"),
                            ("Con astucia y un plan oculto", "Villano")]),
        Question(text: "¿Qué te motiva más?",
                  options: [("Proteger a los demás", "Héroe"),
                            ("El poder y el control", "Villano"),
                            ("Descubrir la verdad", "Estratega")]),
        Question(text: "¿Cómo te describen tus amigos?",
                  options: [("Leal y valiente", "Héroe"),
                            ("Inteligente y calculador(a)", "Estratega"),
                            ("Misterioso(a) e impredecible", "Villano")]),
        Question(text: "En una crisis, tú...",
                  options: [("Tomo el mando y actúo", "Héroe"),
                            ("Observo y planeo en silencio", "Estratega"),
                            ("Busco sacar ventaja de la situación", "Villano")]),
        Question(text: "¿Qué frase te representa mejor?",
                  options: [("El bien siempre triunfa", "Héroe"),
                            ("El conocimiento es poder", "Estratega"),
                            ("Las reglas están para romperse", "Villano")])
    ]

    // MARK: - Estado del cuestionario
    var currentQuestionIndex = 0

    // Colección: Dictionary para acumular el puntaje de cada personaje
    var scores: [String: Int] = [:]

    // Bandera usada por la estructura de control que evita cambiar la respuesta
    var hasAnsweredCurrentQuestion = false

    // MARK: - UI
    let progressLabel = UILabel()
    let questionLabel = UILabel()
    let stackView = UIStackView()
    var optionButtons: [UIButton] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "¿Qué personaje eres?"
        setupUI()
        loadQuestion(at: currentQuestionIndex)
    }

    // MARK: - Construcción de la interfaz
    private func setupUI() {
        progressLabel.font = .systemFont(ofSize: 14, weight: .medium)
        progressLabel.textColor = .gray
        progressLabel.textAlignment = .center
        progressLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressLabel)

        questionLabel.font = .boldSystemFont(ofSize: 20)
        questionLabel.numberOfLines = 0
        questionLabel.textAlignment = .center
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(questionLabel)

        stackView.axis = .vertical
        stackView.spacing = 14
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: safe.topAnchor, constant: 24),
            progressLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            questionLabel.topAnchor.constraint(equalTo: progressLabel.bottomAnchor, constant: 16),
            questionLabel.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            questionLabel.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),

            stackView.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 32),
            stackView.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24)
        ])
    }

    // MARK: - Cargar una pregunta y generar sus botones
    // Estructura iterativa (for-in) para crear un botón por cada opción disponible.
    private func loadQuestion(at index: Int) {
        hasAnsweredCurrentQuestion = false

        for button in optionButtons {
            button.removeFromSuperview()
        }
        optionButtons.removeAll()

        let question = questions[index]
        progressLabel.text = "Pregunta \(index + 1) de \(questions.count)"
        questionLabel.text = question.text

        for option in question.options {
            let button = UIButton(type: .system)
            button.setTitle(option.text, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 17)
            button.titleLabel?.numberOfLines = 0
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = UIColor(white: 0.95, alpha: 1)
            button.layer.cornerRadius = 10
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.black.cgColor
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            button.heightAnchor.constraint(greaterThanOrEqualToConstant: 54).isActive = true
            button.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            optionButtons.append(button)
        }
    }

    // MARK: - Manejo de la respuesta seleccionada
    @objc private func optionTapped(_ sender: UIButton) {
        // Estructura de control: si la pregunta ya fue respondida, se ignora el toque
        // (evita que el usuario cambie su respuesta, requisito "c").
        guard !hasAnsweredCurrentQuestion else { return }
        hasAnsweredCurrentQuestion = true

        // for-in para deshabilitar todas las opciones de la pregunta actual.
        // Operador ternario para resaltar cuál fue la opción elegida.
        for button in optionButtons {
            button.isEnabled = false
            button.alpha = (button == sender) ? 1.0 : 0.4
        }

        guard let title = sender.title(for: .normal),
              let selected = questions[currentQuestionIndex].options.first(where: { $0.text == title }) else {
            return
        }

        // Operador de asignación compuesta (+=) para acumular el puntaje del personaje.
        scores[selected.character, default: 0] += 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            self.currentQuestionIndex += 1

            if self.currentQuestionIndex < self.questions.count {
                self.loadQuestion(at: self.currentQuestionIndex)
            } else {
                self.showResult()
            }
        }
    }

    // MARK: - Mostrar el resultado final (requisito "d")
    private func showResult() {
        // max(by:) recorre el diccionario comparando valores (operador <)
        // para encontrar el personaje con más puntos.
        guard let winner = scores.max(by: { $0.value < $1.value }) else { return }

        let description: String
        // Estructura de control switch para mapear el resultado a su descripción.
        switch winner.key {
        case "Héroe":
            description = "Eres valiente, leal y siempre estás dispuesto a proteger a los demás, sin importar el riesgo."
        case "Villano":
            description = "Eres astuto, ambicioso y no temes romper las reglas para conseguir lo que quieres."
        case "Estratega":
            description = "Eres inteligente, observador y prefieres pensar cuidadosamente antes de actuar."
        default:
            description = "Tu personalidad es única: ¡una mezcla de todo un poco!"
        }

        progressLabel.text = "Resultado"
        questionLabel.text = "Eres: \(winner.key)"

        for button in optionButtons { button.removeFromSuperview() }
        optionButtons.removeAll()

        let resultLabel = UILabel()
        resultLabel.text = description
        resultLabel.numberOfLines = 0
        resultLabel.font = .systemFont(ofSize: 17)
        resultLabel.textAlignment = .center
        stackView.addArrangedSubview(resultLabel)
    }
}
