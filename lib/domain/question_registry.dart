import 'question.dart';

/// Canonical registry of all questions available in the app.
///
/// This list is finite and intentionally compiled into the binary.
/// Questions are identified exclusively by their [id].
///
/// Do NOT reuse an id for a different question.
/// Text may change; identity must not.
class QuestionRegistry {
  const QuestionRegistry._(); // Prevent instantiation

  static const String identityQuestionId = 'system_identity_name';

  /// Ordered list of all questions.
  ///
  /// Order does not imply presentation order; selection logic
  /// is handled elsewhere.
  static const List<Question> all = [
    Question(
      id: identityQuestionId,
      text: '¿Cómo te gusta que te llamen?',
      category: 'system',
    ),
    Question(
      id: 'childhood_place',
      text: '¿Cómo era el lugar donde creciste?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_memory_early',
      text: '¿Cuál es uno de tus recuerdos más antiguos?',
      category: 'childhood',
    ),
    Question(
      id: 'parents_description',
      text: '¿Cómo describirías a tus padres?',
      category: 'family',
    ),
    Question(
      id: 'school_experience',
      text: '¿Cómo fue tu experiencia en la escuela?',
      category: 'education',
    ),
    Question(
      id: 'work_pride',
      text: '¿De qué trabajo o actividad te sentiste más orgulloso?',
      category: 'work',
    ),
    Question(
      id: 'life_turning_point',
      text: '¿Hubo algún momento que cambió el rumbo de tu vida?',
      category: 'life',
    ),
    Question(
      id: 'important_people',
      text: '¿Qué personas han sido más importantes para ti?',
      category: 'relationships',
    ),
    Question(
      id: 'love_definition',
      text: '¿Qué significa para ti el amor?',
      category: 'values',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'fear_definition',
      text: '¿A qué le has tenido más miedo en la vida?',
      category: 'values',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'daily_thoughts',
      text: '¿En qué pensaste hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_annoyance',
      text: '¿Hubo algo que te molestara hoy?',
      category: 'present',
      repeatable: true,
      cooldownDays: 1,
    ),
    Question(
      id: 'current_worries',
      text: '¿Hay algo que te preocupe últimamente?',
      category: 'present',
      repeatable: true,
      cooldownDays: 30,
    ),
    Question(
      id: 'unanswered_question',
      text: '¿Hay algo que sientas que nadie te ha preguntado?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 90,
    ),
    Question(
      id: 'message_future',
      text: 'Si pudieras dejar un mensaje para el futuro, ¿qué dirías?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'childhood_self_narrative_origin',
      text:
          'Si tuvieras que identificar el momento en que comenzó la historia que hoy cuentas sobre ti mismo, ¿cuál sería y por qué?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_implicit_rule_internalized',
      text:
          '¿Qué regla no escrita aprendiste en tu infancia que aún hoy influye en tus decisiones?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_emotional_silence_pattern',
      text:
          '¿Qué emoción aprendiste a ocultar cuando eras niño y qué consecuencias tuvo eso en tu vida adulta?',
      category: 'childhood',
    ),
    Question(
      id: 'family_loyalty_conflict',
      text:
          '¿Alguna vez sentiste que ser leal a tu familia implicaba traicionarte a ti mismo?',
      category: 'family',
    ),
    Question(
      id: 'parents_unspoken_expectation',
      text:
          '¿Qué expectativa crees que tus padres tenían sobre ti aunque nunca la expresaran abiertamente?',
      category: 'family',
    ),
    Question(
      id: 'childhood_identity_mask',
      text:
          '¿Qué versión de ti desarrollaste para adaptarte a tu entorno familiar?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_powerlessness_memory',
      text:
          '¿Recuerdas una situación en la que te sentiste completamente sin poder y cómo interpretas hoy ese recuerdo?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_justice_framework_origin',
      text:
          '¿Cómo se formó tu idea de lo que es justo o injusto durante tu infancia?',
      category: 'values',
    ),
    Question(
      id: 'family_conflict_internal_effect',
      text:
          '¿Qué conflicto familiar moldeó más tu forma de relacionarte con los demás?',
      category: 'family',
    ),
    Question(
      id: 'childhood_shame_core',
      text:
          '¿Hay alguna vergüenza infantil que haya influido silenciosamente en tu autoestima adulta?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_competence_origin',
      text:
          '¿En qué momento comenzaste a sentirte competente o incapaz, y qué lo detonó?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_attachment_pattern',
      text:
          '¿Cómo describirías el tipo de apego que desarrollaste hacia tus figuras de cuidado?',
      category: 'relationships',
    ),
    Question(
      id: 'childhood_role_assignment',
      text:
          '¿Qué papel ocupabas dentro de tu familia y cómo crees que ese rol te condicionó?',
      category: 'family',
    ),
    Question(
      id: 'childhood_resilience_source',
      text:
          '¿Qué te permitió resistir o adaptarte a las dificultades que viviste de pequeño?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_memory_reinterpretation',
      text:
          '¿Hay algún recuerdo de infancia que hoy interpretes de manera diferente a como lo hacías antes?',
      category: 'childhood',
    ),
    Question(
      id: 'family_affection_ambiguity',
      text:
          '¿Hubo gestos de afecto que en su momento no comprendiste completamente?',
      category: 'family',
    ),
    Question(
      id: 'childhood_trust_foundation',
      text:
          '¿En qué experiencias tempranas se construyó tu capacidad de confiar en otros?',
      category: 'relationships',
    ),
    Question(
      id: 'childhood_self_protection_strategy',
      text:
          '¿Qué estrategia desarrollaste para protegerte emocionalmente cuando eras niño?',
      category: 'identity',
    ),
    Question(
      id: 'family_silence_topics',
      text:
          '¿Qué temas eran imposibles de hablar en tu hogar y qué efecto tuvo ese silencio?',
      category: 'family',
    ),
    Question(
      id: 'childhood_anger_expression',
      text:
          '¿Cómo se expresaba tu enojo cuando eras pequeño y qué aprendiste sobre esa emoción?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_dependency_awareness',
      text:
          '¿Cuándo tomaste conciencia de que dependías de otros para sobrevivir y cómo viviste esa dependencia?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_envy_origin',
      text:
          '¿Qué fue lo primero que envidiaste en la vida y qué te reveló esa envidia sobre tus deseos?',
      category: 'values',
    ),
    Question(
      id: 'family_authority_internalization',
      text:
          '¿Cómo interiorizaste la autoridad y cómo se manifiesta hoy en tu relación con el poder?',
      category: 'values',
    ),
    Question(
      id: 'childhood_guilt_experience',
      text:
          '¿Recuerdas una culpa que cargaste durante mucho tiempo en tu infancia?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_moral_dilemma',
      text:
          '¿Tuviste alguna experiencia temprana que te obligara a elegir entre lo correcto y lo conveniente?',
      category: 'values',
    ),
    Question(
      id: 'childhood_comparison_pattern',
      text:
          '¿Cómo influyó la comparación con otros en tu construcción de identidad?',
      category: 'identity',
    ),
    Question(
      id: 'family_failure_narrative',
      text:
          '¿Existía en tu familia una narrativa de fracaso o éxito que te afectara personalmente?',
      category: 'family',
    ),
    Question(
      id: 'childhood_self_silencing',
      text:
          '¿Hubo momentos en los que decidiste no hablar para evitar consecuencias?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_imagined_escape',
      text:
          '¿Fantaseabas con escapar o cambiar radicalmente tu entorno, y qué decía eso de tu situación?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_first_autonomy',
      text: '¿Recuerdas el primer acto en que sentiste verdadera autonomía?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_mistaken_belief',
      text:
          '¿Qué creencia equivocada sobre ti mismo se formó en tu infancia y cuánto tardaste en desmontarla?',
      category: 'identity',
    ),
    Question(
      id: 'family_sacrifice_perception',
      text:
          '¿Cómo percibías los sacrificios de tus padres cuando eras niño y cómo los interpretas ahora?',
      category: 'family',
    ),
    Question(
      id: 'childhood_identity_fragment',
      text:
          '¿Sientes que dejaste alguna parte de ti en la infancia que no recuperaste después?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_dominant_emotion',
      text:
          'Si tuvieras que elegir una emoción dominante de tu infancia, ¿cuál sería y por qué?',
      category: 'childhood',
    ),
    Question(
      id: 'childhood_value_conflict',
      text:
          '¿Hubo valores familiares que aceptaste exteriormente pero cuestionaste internamente?',
      category: 'values',
    ),
    Question(
      id: 'childhood_attachment_loss',
      text:
          '¿Cómo manejabas la separación de personas importantes en tu niñez?',
      category: 'relationships',
    ),
    Question(
      id: 'childhood_self_concept_shift',
      text: '¿En qué momento cambió la forma en que te definías a ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_control_experience',
      text:
          '¿Sentías que tenías control sobre tu entorno o que estabas a merced de él?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_internal_dialogue',
      text: '¿Cómo era tu diálogo interno cuando eras niño?',
      category: 'identity',
    ),
    Question(
      id: 'childhood_moral_origin_story',
      text:
          '¿Qué experiencia específica consideras el origen de tu brújula moral?',
      category: 'values',
    ),
    Question(
      id: 'childhood_unresolved_question',
      text: '¿Qué pregunta sobre tu infancia sigue sin respuesta clara?',
      category: 'childhood',
    ),
    Question(
      id: 'adolescence_self_view_change',
      text: '¿En qué momento empezaste a verte diferente de cuando eras niño?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_first_big_decision',
      text:
          '¿Cuál fue la primera decisión importante que tomaste por ti mismo?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_rebellion_reason',
      text:
          '¿Te rebelaste contra algo o alguien en tu juventud y por qué lo hiciste?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_insecurity_source',
      text: '¿Qué era lo que más te hacía sentir inseguro cuando eras joven?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_pride_moment',
      text:
          '¿Hubo algo que hiciste en tu juventud que te hizo sentir capaz por primera vez?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_friendship_loyalty',
      text:
          '¿Qué significaba para ti la lealtad entre amigos cuando eras joven?',
      category: 'relationships',
    ),
    Question(
      id: 'adolescence_peer_pressure',
      text: '¿Alguna vez hiciste algo solo por presión de otros?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_authority_view',
      text: '¿Cómo veías a las figuras de autoridad cuando eras adolescente?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_first_failure',
      text: '¿Cuál fue uno de tus primeros fracasos y cómo lo enfrentaste?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_identity_confusion',
      text: '¿Hubo una etapa en la que no sabías bien quién querías ser?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_work_ethic_origin',
      text: '¿Cuándo empezaste a entender el valor del trabajo?',
      category: 'work',
    ),
    Question(
      id: 'adolescence_money_perception',
      text: '¿Qué pensabas del dinero cuando eras joven?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_first_love_lesson',
      text: '¿Qué aprendiste de tu primera experiencia amorosa?',
      category: 'relationships',
    ),
    Question(
      id: 'adolescence_emotional_control',
      text: '¿Cómo manejabas tus emociones fuertes en la adolescencia?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_anger_expression',
      text: '¿Cómo expresabas tu enojo cuando eras joven?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_self_doubt',
      text: '¿Hubo algo que dudabas mucho de ti mismo en la adolescencia?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_turning_point',
      text:
          '¿Recuerdas un momento que cambió tu forma de pensar en la juventud?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_family_distance',
      text:
          '¿Te sentiste más cerca o más lejos de tu familia durante la adolescencia?',
      category: 'family',
    ),
    Question(
      id: 'adolescence_role_shift',
      text:
          '¿Cambió tu papel dentro de la familia en la adolescencia respecto de tu niñez?',
      category: 'family',
    ),
    Question(
      id: 'adolescence_secret_kept',
      text:
          '¿Guardabas algún pensamiento o problema que no compartías con nadie?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_future_expectation',
      text: '¿Qué esperabas de tu vida cuando tenías alrededor de veinte años?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_risk_taken',
      text: '¿Tomaste algún riesgo importante en tu juventud?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_friend_loss',
      text: '¿Perdiste alguna amistad importante en la adolescencia?',
      category: 'relationships',
    ),
    Question(
      id: 'adolescence_values_questioned',
      text: '¿Hubo valores que empezaste a cuestionar en la adolescencia?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_role_model_change',
      text: '¿Cambió la persona que admirabas al crecer?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_moral_boundary',
      text:
          '¿Recuerdas una situación en la que decidiste no cruzar cierto límite?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_self_reliance',
      text: '¿Cuándo empezaste a sentir que podías valerte por ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_failure_shame',
      text: '¿Hubo algún error que te causó vergüenza por mucho tiempo?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_dream_abandoned',
      text: '¿Dejaste algún sueño en la adolescencia?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_character_trait_formed',
      text: '¿Qué rasgo de tu carácter crees que se formó en tu juventud?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_responsibility_awareness',
      text:
          '¿Cuándo sentiste por primera vez el peso de una responsabilidad real?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_self_image_vs_reality',
      text:
          '¿La imagen que tenías de ti mismo coincidía con lo que otros veían?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_fear_future',
      text: '¿Había algo del futuro que te preocupara en la adolescencia?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_principle_defense',
      text: '¿Defendiste alguna vez un principio aunque te trajera problemas?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_loneliness_experience',
      text: '¿Te sentiste solo en algún momento de tu juventud?',
      category: 'adolescence',
    ),
    Question(
      id: 'adolescence_self_change_intentional',
      text: '¿Intentaste cambiar algo de tu forma de ser en la adolescencia?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_learning_from_mistake',
      text: '¿Qué error juvenil te dejó una enseñanza clara?',
      category: 'life',
    ),
    Question(
      id: 'adolescence_confidence_source',
      text:
          '¿De dónde sacabas confianza cuando dudabas de ti en la adolescencia?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_definition_success',
      text: '¿Cómo definías el éxito cuando eras joven?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_definition_failure',
      text: '¿Qué considerabas un fracaso en la adolescencia?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_emotional_support',
      text:
          '¿Con quién hablaste cuando atravesabas un problema serio en tu juventud?',
      category: 'relationships',
    ),
    Question(
      id: 'adolescence_inner_conflict',
      text: '¿Recuerdas algún conflicto interno que te costó resolver?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_self_respect_origin',
      text: '¿En qué momento empezaste a respetarte a ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_personal_limit',
      text: '¿Cuál fue el límite personal que aprendiste a no cruzar?',
      category: 'values',
    ),
    Question(
      id: 'adolescence_identity_choice',
      text:
          '¿Hubo algo que decidiste conscientemente que querías ser o no ser?',
      category: 'identity',
    ),
    Question(
      id: 'adolescence_life_direction_decision',
      text: '¿Cuándo sentiste que tu vida empezaba a tomar dirección propia?',
      category: 'life',
    ),
    Question(
      id: 'first_real_job_experience',
      text: '¿Cómo fue el primer trabajo que tuviste y qué aprendiste de él?',
      category: 'work',
    ),
    Question(
      id: 'work_responsibility_weight',
      text:
          '¿Cuándo sentiste por primera vez el peso real de una responsabilidad laboral?',
      category: 'work',
    ),
    Question(
      id: 'work_failure_hard',
      text: '¿Cuál ha sido uno de los fracasos laborales que más te marcó?',
      category: 'work',
    ),
    Question(
      id: 'work_character_test',
      text: '¿En qué momento el trabajo puso a prueba tu carácter?',
      category: 'work',
    ),
    Question(
      id: 'money_first_realization',
      text: '¿Cuándo entendiste realmente el valor del dinero?',
      category: 'values',
    ),
    Question(
      id: 'money_mistake_memory',
      text: '¿Recuerdas un error importante relacionado con el dinero?',
      category: 'values',
    ),
    Question(
      id: 'money_security_meaning',
      text: '¿Qué significa para ti sentir seguridad económica?',
      category: 'values',
    ),
    Question(
      id: 'money_vs_time_choice',
      text: '¿Alguna vez tuviste que elegir entre tiempo y dinero?',
      category: 'values',
    ),
    Question(
      id: 'work_ethic_definition',
      text: '¿Qué significa para ti trabajar bien?',
      category: 'work',
    ),
    Question(
      id: 'work_unfair_situation',
      text: '¿Viviste alguna situación laboral que consideraras injusta?',
      category: 'work',
    ),
    Question(
      id: 'authority_conflict_work',
      text:
          '¿Tuviste algún conflicto fuerte con una figura de autoridad en el trabajo?',
      category: 'work',
    ),
    Question(
      id: 'work_quit_decision',
      text: '¿Alguna vez decidiste dejar un trabajo por principios?',
      category: 'work',
    ),
    Question(
      id: 'work_loyalty_test',
      text:
          '¿El trabajo te obligó alguna vez a elegir entre lealtad y conveniencia?',
      category: 'values',
    ),
    Question(
      id: 'work_identity_connection',
      text:
          '¿Qué tanto de tu identidad está ligado a lo que haces o hiciste como trabajo?',
      category: 'identity',
    ),
    Question(
      id: 'adult_first_big_risk',
      text: '¿Cuál fue uno de los mayores riesgos que tomaste como adulto?',
      category: 'life',
    ),
    Question(
      id: 'adult_regret_decision',
      text: '¿Hay una decisión adulta que todavía cuestionas?',
      category: 'life',
    ),
    Question(
      id: 'adult_maturity_realization',
      text: '¿Cuándo sentiste que realmente te habías convertido en adulto?',
      category: 'identity',
    ),
    Question(
      id: 'adult_sacrifice_memory',
      text: '¿Qué sacrificio hiciste que cambió el rumbo de tu vida?',
      category: 'life',
    ),
    Question(
      id: 'adult_resilience_source',
      text: '¿Qué te ayudó a seguir adelante en momentos difíciles?',
      category: 'identity',
    ),
    Question(
      id: 'adult_failure_recovery',
      text:
          '¿Cómo te recuperaste de uno de los momentos más difíciles de tu vida?',
      category: 'life',
    ),
    Question(
      id: 'adult_moral_boundary',
      text:
          '¿Hubo una situación en la que defendiste tus principios aunque te costara caro?',
      category: 'values',
    ),
    Question(
      id: 'adult_identity_shift',
      text: '¿Qué experiencia cambió la forma en que te ves a ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'adult_friendship_loss',
      text: '¿Perdiste alguna amistad importante por diferencias profundas?',
      category: 'relationships',
    ),
    Question(
      id: 'adult_trust_break',
      text: '¿Alguna vez alguien rompió tu confianza de manera significativa?',
      category: 'relationships',
    ),
    Question(
      id: 'adult_forgiveness_process',
      text: '¿Cómo decides perdonar a alguien que te ha lastimado?',
      category: 'values',
    ),
    Question(
      id: 'adult_self_respect_moment',
      text:
          '¿Cuándo sentiste que te respetaste a ti mismo por una decisión difícil?',
      category: 'identity',
    ),
    Question(
      id: 'adult_family_priority',
      text: '¿En qué momento entendiste que tu familia debía ser prioridad?',
      category: 'family',
    ),
    Question(
      id: 'adult_parenthood_fear',
      text:
          '¿Qué miedo sentiste cuando asumiste la responsabilidad de ser padre?',
      category: 'family',
    ),
    Question(
      id: 'adult_parenthood_pride',
      text: '¿Qué momento como padre te hizo sentir más orgulloso?',
      category: 'family',
    ),
    Question(
      id: 'adult_parenthood_regret',
      text: '¿Hay algo que hubieras querido hacer diferente como padre?',
      category: 'family',
    ),
    Question(
      id: 'adult_emotional_control',
      text:
          '¿Cómo aprendiste a controlar tus emociones en situaciones difíciles?',
      category: 'identity',
    ),
    Question(
      id: 'adult_loneliness_experience',
      text:
          '¿Hubo un momento en que te sentiste profundamente solo siendo adulto?',
      category: 'life',
    ),
    Question(
      id: 'adult_definition_success',
      text: '¿Cómo definirías el éxito hoy?',
      category: 'values',
    ),
    Question(
      id: 'adult_definition_failure',
      text: '¿Cómo definirías el fracaso hoy?',
      category: 'values',
    ),
    Question(
      id: 'adult_biggest_mistake',
      text: '¿Cuál consideras que ha sido uno de tus mayores errores?',
      category: 'life',
    ),
    Question(
      id: 'adult_learning_from_pain',
      text: '¿Qué dolor te dejó una enseñanza que todavía aplicas?',
      category: 'life',
    ),
    Question(
      id: 'adult_courage_example',
      text: '¿En qué momento actuaste con valentía aunque sintieras miedo?',
      category: 'identity',
    ),
    Question(
      id: 'adult_self_doubt_period',
      text: '¿Hubo un periodo en el que dudaste seriamente de ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'adult_turning_point_clear',
      text: '¿Qué evento cambió claramente el rumbo de tu vida adulta?',
      category: 'life',
    ),
    Question(
      id: 'adult_core_value_strengthened',
      text: '¿Qué valor se fortaleció más con el paso de los años?',
      category: 'values',
    ),
    Question(
      id: 'adult_core_value_lost',
      text: '¿Sientes que algún valor se debilitó con el tiempo?',
      category: 'values',
    ),
    Question(
      id: 'adult_identity_constant',
      text: '¿Qué parte de tu forma de ser ha permanecido igual desde joven?',
      category: 'identity',
    ),
    Question(
      id: 'adult_identity_change',
      text: '¿Qué parte de tu carácter cambió más con los años?',
      category: 'identity',
    ),
    Question(
      id: 'adult_internal_conflict',
      text: '¿Qué conflicto interno te ha acompañado durante muchos años?',
      category: 'identity',
    ),
    Question(
      id: 'adult_peace_moment',
      text: '¿Recuerdas un momento en que sentiste verdadera paz interior?',
      category: 'life',
    ),
    Question(
      id: 'adult_unfinished_business',
      text: '¿Hay algo importante que sientas que quedó inconcluso?',
      category: 'life',
    ),
    Question(
      id: 'adult_legacy_reflection',
      text: '¿Qué te gustaría que otros recuerden de ti?',
      category: 'legacy',
    ),
    Question(
      id: 'love_first_serious_meaning',
      text: '¿Qué aprendiste del primer amor que tomaste en serio?',
      category: 'relationships',
    ),
    Question(
      id: 'love_biggest_mistake',
      text:
          '¿Cuál fue uno de los errores más grandes que cometiste en una relación?',
      category: 'relationships',
    ),
    Question(
      id: 'love_trust_building',
      text: '¿Cómo se construye la confianza en una pareja?',
      category: 'relationships',
    ),
    Question(
      id: 'love_trust_breaking',
      text: '¿Qué puede romper definitivamente la confianza en una relación?',
      category: 'relationships',
    ),
    Question(
      id: 'marriage_expectation_vs_reality',
      text: '¿El matrimonio fue como lo imaginabas?',
      category: 'relationships',
    ),
    Question(
      id: 'marriage_hardest_moment',
      text:
          '¿Cuál fue uno de los momentos más difíciles dentro de tus relaciones de pareja?',
      category: 'relationships',
    ),
    Question(
      id: 'marriage_strongest_moment',
      text:
          '¿Cuál fue uno de los momentos que más fortaleció la relación de pareja que más añoras?',
      category: 'relationships',
    ),
    Question(
      id: 'love_sacrifice_memory',
      text: '¿Qué sacrificio hiciste por amor?',
      category: 'relationships',
    ),
    Question(
      id: 'love_unspoken_feelings',
      text: '¿Hay algo que sentiste en una relación y nunca expresaste?',
      category: 'relationships',
    ),
    Question(
      id: 'love_definition_now',
      text: '¿Qué significa para ti amar a alguien hoy?',
      category: 'values',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'betrayal_experience_memory',
      text: '¿Alguna vez te sentiste traicionado por alguien cercano?',
      category: 'relationships',
    ),
    Question(
      id: 'forgiveness_hard_case',
      text: '¿Cuál ha sido el perdón más difícil que has tenido que dar?',
      category: 'values',
    ),
    Question(
      id: 'regret_relationship',
      text: '¿Hay una relación que desearías haber manejado de otra manera?',
      category: 'relationships',
    ),
    Question(
      id: 'loss_first_deep',
      text: '¿Cuál fue la pérdida que más te dolió en la vida?',
      category: 'life',
    ),
    Question(
      id: 'loss_grief_process',
      text: '¿Cómo viviste el duelo cuando perdiste a alguien importante?',
      category: 'life',
    ),
    Question(
      id: 'loss_unfinished_words',
      text: '¿Quedó algo que quisieras haber dicho antes de perder a alguien?',
      category: 'life',
    ),
    Question(
      id: 'death_view_change',
      text:
          '¿Cambió tu forma de ver la vida después de enfrentar una muerte cercana?',
      category: 'values',
    ),
    Question(
      id: 'aging_first_awareness',
      text: '¿Cuándo empezaste a sentir el paso del tiempo en tu cuerpo?',
      category: 'life',
    ),
    Question(
      id: 'health_scare_memory',
      text: '¿Has tenido algún susto de salud que te haya hecho reflexionar?',
      category: 'life',
    ),
    Question(
      id: 'body_relationship_now',
      text: '¿Cómo describirías tu relación actual con tu propio cuerpo?',
      category: 'identity',
    ),
    Question(
      id: 'aging_fear',
      text: '¿Qué es lo que más te preocupa del envejecimiento?',
      category: 'life',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'aging_acceptance',
      text: '¿Qué has aprendido gracias al paso de los años?',
      category: 'life',
    ),
    Question(
      id: 'time_regret',
      text: '¿Hay algo que sientas que debiste haber hecho antes?',
      category: 'life',
    ),
    Question(
      id: 'time_wasted_memory',
      text: '¿Sientes que desperdiciaste tiempo en algo importante?',
      category: 'life',
    ),
    Question(
      id: 'life_biggest_risk',
      text: '¿Cuál fue la decisión más arriesgada que tomaste?',
      category: 'life',
    ),
    Question(
      id: 'life_biggest_reward',
      text:
          '¿Cuál ha sido la mayor recompensa que recibiste por una decisión difícil?',
      category: 'life',
    ),
    Question(
      id: 'life_turning_point_clearer',
      text: '¿Cuál fue el punto más claro en que tu vida cambió de dirección?',
      category: 'life',
    ),
    Question(
      id: 'life_internal_strength_source',
      text: '¿De dónde sacaste fuerza en tus momentos más duros?',
      category: 'identity',
    ),
    Question(
      id: 'life_hidden_fear',
      text: '¿Hay un miedo que casi nadie conoce sobre ti?',
      category: 'identity',
    ),
    Question(
      id: 'life_hidden_pride',
      text: '¿Hay algo de lo que te sientes orgulloso y casi nunca mencionas?',
      category: 'identity',
    ),
    Question(
      id: 'life_unresolved_conflict',
      text: '¿Hay un conflicto que aún no has logrado resolver?',
      category: 'life',
    ),
    Question(
      id: 'life_internal_peace_definition',
      text: '¿Qué significa para ti estar en paz contigo mismo?',
      category: 'values',
    ),
    Question(
      id: 'life_spiritual_belief_change',
      text: '¿Ha cambiado tu forma de ver a Dios o lo espiritual con los años?',
      category: 'values',
    ),
    Question(
      id: 'life_faith_test',
      text: '¿Tuviste algún momento en que tu fe fue puesta a prueba?',
      category: 'values',
    ),
    Question(
      id: 'life_principle_non_negotiable',
      text: '¿Qué principio nunca estarías dispuesto a abandonar?',
      category: 'values',
    ),
    Question(
      id: 'life_identity_core',
      text:
          'Si tuvieras que resumir quién eres en una frase honesta, ¿qué dirías?',
      category: 'identity',
    ),
    Question(
      id: 'life_biggest_lesson',
      text:
          '¿Cuál consideras que ha sido la lección más importante que te dejó la vida?',
      category: 'life',
    ),
    Question(
      id: 'life_message_to_younger_self',
      text: '¿Qué consejo le darías a tu versión de veinte años?',
      category: 'legacy',
    ),
    Question(
      id: 'life_message_to_children',
      text: '¿Qué enseñanza quisieras que tus hijos nunca olviden?',
      category: 'legacy',
    ),
    Question(
      id: 'life_unasked_question',
      text: '¿Hay algo importante sobre tu vida que casi nadie conoce?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'life_if_time_short',
      text: 'Si supieras que te queda poco tiempo, ¿qué harías diferente?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'legacy_personal_definition',
      text:
          'Si alguien preguntara quién fuiste realmente, ¿qué te gustaría que respondieran?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'legacy_hidden_story',
      text: '¿Hay una historia importante de tu vida que casi nadie conoce?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_private_struggle',
      text: '¿Cuál fue una lucha personal que llevaste en silencio?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_secret_pride',
      text: '¿Qué logro casi nunca mencionas?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_unspoken_regret',
      text: '¿Hay algo que te hubiera gustado decir y nunca dijiste?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_personal_truth',
      text: '¿Cuál es una verdad sobre ti que pocas personas entienden?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_character_summary',
      text:
          'Si tuvieras que describir tu carácter con honestidad, ¿qué dirías?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_misunderstood_trait',
      text:
          '¿Hay algo de tu forma de ser que haya sido malinterpretado por otros?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_biggest_sacrifice',
      text: '¿Cuál fue el mayor sacrificio que hiciste por alguien más?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_love_expression',
      text: '¿Cómo demostrabas amor cuando no sabías cómo decirlo?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_message_future_family',
      text:
          '¿Qué mensaje quisieras que tu familia recuerde cuando tú ya no estés?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'legacy_value_to_keep',
      text: '¿Qué valor quisieras que se conserve en tu familia después de ti?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_value_to_change',
      text: '¿Qué costumbre familiar crees que debería cambiarse en el futuro?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_lesson_from_failure',
      text: '¿Qué fracaso tuyo podría servir de enseñanza para otros?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_lesson_from_pain',
      text:
          '¿Qué dolor que viviste puede ayudar a alguien más a entender la vida?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_hidden_strength',
      text: '¿Cuál fue tu mayor fortaleza en momentos difíciles?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_hidden_weakness',
      text: '¿Cuál fue una debilidad que te costó aceptar?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_unfinished_dream',
      text: '¿Hay un sueño que quedó pendiente?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_prayer_or_wish',
      text:
          'Si pudieras dejar una oración o deseo para el futuro, ¿cuál sería?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'legacy_identity_core_belief',
      text: '¿Qué creencia te sostuvo durante los años más difíciles?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_mistake_you_forgave',
      text:
          '¿Cuál fue el error más difícil que tuviste que perdonarte a ti mismo?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_principle_never_break',
      text: '¿Qué principio nunca traicionaste?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_secret_fear',
      text: '¿Qué miedo has guardado durante muchos años?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_person_you_tried_to_be',
      text: '¿Qué tipo de hombre intentaste ser a lo largo de tu vida?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_moment_of_real_pride',
      text: '¿En qué momento sentiste que tu vida había valido la pena?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_message_about_time',
      text:
          '¿Qué has entendido sobre el tiempo que quisieras que otros aprendan?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_what_you_would_repeat',
      text: '¿Qué parte de tu vida repetirías sin cambiar nada?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_what_you_would_change',
      text: '¿Qué parte de tu vida cambiarías si pudieras volver atrás?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_private_apology',
      text:
          '¿Hay alguien a quien quisieras pedirle perdón aunque nunca lo hayas hecho?',
      category: 'legacy',
    ),
    Question(
      id: 'legacy_private_gratitude',
      text: '¿Hay alguien a quien nunca le agradeciste lo suficiente?',
      category: 'legacy',
    ),
    Question(
      id: 'meta_unasked_question_deep',
      text: '¿Qué pregunta importante nadie te ha hecho nunca?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'meta_identity_unknown',
      text: '¿Hay algo sobre ti que ni siquiera tú entiendes del todo?',
      category: 'meta',
    ),
    Question(
      id: 'meta_hidden_layer',
      text: '¿Sientes que hay una parte de ti que casi nadie ha visto?',
      category: 'meta',
    ),
    Question(
      id: 'meta_inner_truth',
      text: '¿Cuál es la verdad más honesta que puedes decir sobre tu vida?',
      category: 'meta',
    ),
    Question(
      id: 'meta_if_no_judgment',
      text: 'Si supieras que nadie te va a juzgar, ¿qué dirías de tu vida?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'meta_life_meaning_now',
      text: '¿Qué sentido tiene tu vida para ti hoy?',
      category: 'meta',
      repeatable: true,
      cooldownDays: 180,
    ),
    Question(
      id: 'meta_final_message_record',
      text:
          'Si esta fuera la última vez que puedes dejar un mensaje grabado, ¿qué dirías?',
      category: 'legacy',
      repeatable: true,
      cooldownDays: 365,
    ),
    Question(
      id: 'daily_thought_most_present',
      text: '¿Cuál fue el pensamiento que más te acompañó hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_emotion_strongest',
      text: '¿Qué emoción sentiste con más fuerza hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_small_joy',
      text: '¿Hubo algo pequeño que te dio alegría hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_annoyance_specific',
      text: '¿Qué fue lo que más te molestó hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_gratitude_item',
      text: '¿Por qué te sientes agradecido hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_energy_level',
      text: '¿Cómo describirías tu nivel de energía hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_body_state',
      text: '¿Cómo se siente tu cuerpo hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_worry_present',
      text: '¿Hay algo que te esté preocupando hoy?',
      category: 'present',
      repeatable: true,
      cooldownDays: 7,
    ),
    Question(
      id: 'daily_memory_triggered',
      text: '¿Recordaste algo del pasado hoy? ¿Qué fue?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_conversation_meaningful',
      text: '¿Tuviste hoy una conversación que te dejó pensando?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_person_in_mind',
      text: '¿En quién pensaste hoy y por qué?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_regret_small',
      text: '¿Hay algo pequeño que hubieras hecho diferente hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_pride_small',
      text: '¿Hay algo que hiciste hoy que te dejó satisfecho?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_value_lived',
      text: '¿Viviste hoy de acuerdo con tus valores?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_moment_of_silence',
      text: '¿Tuviste hoy un momento de silencio o reflexión?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_unspoken_words',
      text: '¿Hubo algo que quisiste decir hoy y no dijiste?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_surprise_event',
      text: '¿Algo te sorprendió hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_fear_brief',
      text: '¿Sentiste miedo en algún momento del día?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_laughter_reason',
      text: '¿Qué te hizo reír hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_time_reflection',
      text: '¿Sentiste que el día pasó rápido o lento?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_future_thought',
      text: '¿Pensaste hoy en el futuro?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_past_reflection',
      text: '¿Pensaste hoy en el pasado?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_relationship_check',
      text: '¿Cómo te sentiste hoy con las personas que te rodean?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_inner_peace',
      text: '¿Te sentiste en paz hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_inner_conflict',
      text: '¿Tuviste hoy algún conflicto interno?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_decision_reflection',
      text: '¿Tomaste hoy alguna decisión que consideres importante?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_weather_effect',
      text: '¿El clima influyó en tu estado de ánimo hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_health_note',
      text: '¿Cómo estuvo tu salud hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_learning_today',
      text: '¿Aprendiste algo hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_meaningful_image',
      text: '¿Hubo alguna imagen o escena del día que quieras recordar?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_thought_about_family',
      text: '¿Qué pensaste hoy sobre tu familia?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_self_evaluation',
      text: '¿Cómo te evaluarías hoy como persona?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_energy_source',
      text: '¿Qué te dio energía hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_energy_drain',
      text: '¿Qué te quitó energía hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_unexpected_feeling',
      text: '¿Sentiste algo inesperado hoy?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_simple_observation',
      text: '¿Qué detalle simple del día quieres dejar registrado?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_message_to_future_self',
      text: '¿Qué quisieras que tu yo del futuro recuerde sobre este día?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'daily_current_state_summary',
      text:
          'Si tuvieras que describir cómo estás hoy en una frase, ¿cuál sería?',
      category: 'present',
      repeatable: true,
    ),
    Question(
      id: 'cognitive_error_detection',
      text: '¿Cómo sabes que estás equivocado cuando nadie te lo dice?',
      category: 'identity',
    ),
    Question(
      id: 'cognitive_error_type_bias',
      text:
          '¿Qué tipo de error te cuesta más reconocer: el de cálculo o el de juicio?',
      category: 'identity',
    ),
    Question(
      id: 'cognitive_ignored_information',
      text:
          '¿Qué información ignoras deliberadamente para poder seguir funcionando?',
      category: 'identity',
    ),
    Question(
      id: 'cognitive_projection_pattern',
      text:
          '¿Qué patrón sueles ver en otros que rara vez reconoces en ti mismo?',
      category: 'identity',
    ),
    Question(
      id: 'belief_change_conditions',
      text:
          '¿Qué condiciones tienen que cumplirse para que cambies de opinión de verdad?',
      category: 'values',
    ),
    Question(
      id: 'intrinsic_problem_interest',
      text:
          '¿Qué tipo de problema te resulta naturalmente interesante aunque no te beneficie?',
      category: 'identity',
    ),
    Question(
      id: 'value_conflict_resolution',
      text:
          '¿Qué haces cuando dos valores tuyos entran en conflicto real y no puedes satisfacer ambos?',
      category: 'values',
    ),
    Question(
      id: 'decision_review_frequency',
      text:
          '¿Qué tan seguido revisas decisiones pasadas con intención de corregirte, no de justificarte?',
      category: 'identity',
    ),
    Question(
      id: 'thinking_explainability_limit',
      text:
          '¿Qué parte de tu forma de pensar consideras más difícil de explicar a otros?',
      category: 'identity',
    ),
    Question(
      id: 'trust_signal_heuristics',
      text:
          '¿Qué señales usas para confiar en alguien cuando no tienes evidencia suficiente?',
      category: 'relationships',
    ),
    Question(
      id: 'capacity_for_harm_awareness',
      text:
          '¿Qué tipo de daño sabes que podrías causar, pero eliges no ejercer?',
      category: 'values',
    ),
    Question(
      id: 'strategic_self_activation',
      text:
          '¿En qué situaciones te vuelves más calculador de lo que te gustaría admitir?',
      category: 'identity',
    ),
    Question(
      id: 'internal_opacity_boundary',
      text:
          '¿Qué parte de ti mantienes inaccesible incluso para quienes confían en ti?',
      category: 'identity',
    ),
    Question(
      id: 'intentional_morality_instance',
      text: '¿Cuándo has actuado correctamente por decisión y no por inercia?',
      category: 'values',
    ),
    Question(
      id: 'transparency_cost',
      text:
          '¿Qué perderías si fueras completamente transparente con los demás?',
      category: 'relationships',
    ),
    Question(
      id: 'decision_timing_strategy',
      text: '¿Cómo decides cuándo actuar rápido y cuándo esperar?',
      category: 'identity',
    ),
    Question(
      id: 'deliberate_opportunity_loss',
      text: '¿Qué oportunidades has dejado pasar deliberadamente y por qué?',
      category: 'life',
    ),
    Question(
      id: 'irreversibility_threshold',
      text:
          '¿Qué distingue para ti una decisión irreversible de una que puedes ajustar después?',
      category: 'values',
    ),
    Question(
      id: 'sufficient_information_threshold',
      text: '¿Cómo reconoces que ya tienes suficiente información para actuar?',
      category: 'identity',
    ),
    Question(
      id: 'internal_model_of_others',
      text:
          '¿Cómo construyes una idea de cómo es alguien cuando aún lo conoces poco?',
      category: 'relationships',
    ),
    Question(
      id: 'cognitive_energy_allocation',
      text: '¿En qué decides gastar tu atención y en qué decides no hacerlo?',
      category: 'identity',
    ),
    Question(
      id: 'uncertainty_tolerance',
      text:
          '¿Qué nivel de incertidumbre puedes tolerar antes de sentir la necesidad de actuar?',
      category: 'identity',
    ),
    Question(
      id: 'self_correction_trigger',
      text:
          '¿Qué evento o señal suele hacerte detenerte y replantear lo que estás haciendo?',
      category: 'identity',
    ),
    Question(
      id: 'hidden_motivation_detection',
      text:
          '¿Cómo detectas cuando tus propias motivaciones no son del todo claras?',
      category: 'meta',
    ),
    Question(
      id: 'cognitive_blindspot_awareness',
      text:
          '¿Sospechas que tienes algún punto ciego en tu forma de pensar? ¿Cuál podría ser?',
      category: 'meta',
    ),
    Question(
      id: 'decision_regret_structure',
      text: '¿Qué hace que una decisión te genere arrepentimiento duradero?',
      category: 'life',
    ),
    Question(
      id: 'predictive_model_failure',
      text:
          '¿Recuerdas una ocasión en la que tu lectura de una persona fue completamente incorrecta?',
      category: 'relationships',
    ),
    Question(
      id: 'self_consistency_pressure',
      text:
          '¿Sientes la necesidad de ser consistente con lo que has dicho o hecho antes, incluso si ya no estás de acuerdo?',
      category: 'identity',
    ),
    Question(
      id: 'internal_standard_origin',
      text:
          '¿De dónde crees que provienen los estándares con los que te evalúas?',
      category: 'values',
    ),
    Question(
      id: 'cognitive_tradeoff_awareness',
      text:
          '¿Qué estás sacrificando cuando decides optimizar un área de tu vida sobre otra?',
      category: 'values',
    ),
    Question(
      id: 'inconsistency_recent_action',
      text:
          '¿En qué situación reciente actuaste en contra de lo que dices creer y cómo lo justificaste en ese momento?',
      category: 'identity',
    ),
    Question(
      id: 'past_vs_present_conflict',
      text:
          'Si comparas lo que pensabas hace diez años con lo que piensas hoy, ¿en qué puntos ambas versiones de ti entrarían en conflicto directo?',
      category: 'identity',
    ),
    Question(
      id: 'real_time_silence_decision',
      text:
          '¿Qué decides no decir mientras estás hablando con alguien y cómo tomas esa decisión en el momento?',
      category: 'relationships',
    ),
    Question(
      id: 'prediction_error_pattern',
      text:
          'Cuando imaginas cómo va a reaccionar alguien, ¿en qué te basas y qué tan seguido te equivocas?',
      category: 'relationships',
    ),
    Question(
      id: 'long_term_error_persistence',
      text:
          '¿Qué error mantuviste durante más tiempo del que te hubiera gustado y por qué no lo corregiste antes?',
      category: 'life',
    ),
    Question(
      id: 'self_presentation_editing',
      text:
          '¿Qué parte de lo que muestras a otros está deliberadamente editada y con qué propósito?',
      category: 'identity',
    ),
    Question(
      id: 'internal_justification_shift',
      text:
          '¿Recuerdas una situación en la que cambiaste tu explicación interna después de haber actuado?',
      category: 'identity',
    ),
    Question(
      id: 'value_compromise_threshold',
      text:
          '¿Qué tendría que pasar para que traicionaras un valor que hoy consideras importante?',
      category: 'values',
    ),
    Question(
      id: 'decision_post_rationalization',
      text: '¿En qué casos sientes que decides primero y razonas después?',
      category: 'identity',
    ),
    Question(
      id: 'hidden_motive_detection_failure',
      text:
          '¿Cuándo te diste cuenta de que tus motivos reales eran distintos a los que creías?',
      category: 'meta',
    ),
    Question(
      id: 'repeated_mistake_awareness',
      text:
          '¿Hay un error que sabes que repites aunque lo tengas identificado?',
      category: 'identity',
    ),
    Question(
      id: 'emotional_override_moment',
      text:
          '¿Cuándo fue la última vez que una emoción anuló algo que sabías que era más razonable?',
      category: 'identity',
    ),
    Question(
      id: 'self_deception_instance',
      text:
          '¿En qué situación reciente te diste cuenta de que te estabas engañando a ti mismo?',
      category: 'meta',
    ),
    Question(
      id: 'trust_miscalculation',
      text:
          '¿Confiaste alguna vez en alguien que no debías o desconfiaste de alguien que sí lo merecía?',
      category: 'relationships',
    ),
    Question(
      id: 'internal_conflict_avoidance',
      text:
          '¿Qué conflicto interno has evitado enfrentar y cómo lo mantienes fuera de foco?',
      category: 'identity',
    ),
    Question(
      id: 'identity_inconsistency_awareness',
      text:
          '¿Qué parte de tu identidad sientes que no encaja con el resto de quien eres?',
      category: 'identity',
    ),
    Question(
      id: 'moral_exception_case',
      text:
          '¿En qué situación hiciste una excepción a una regla moral que normalmente respetas?',
      category: 'values',
    ),
    Question(
      id: 'decision_delay_cost',
      text: '¿Cuándo esperar te costó más que haber actuado antes?',
      category: 'life',
    ),
    Question(
      id: 'premature_decision_cost',
      text:
          '¿Cuándo actuar rápido te llevó a un resultado peor del que habrías tenido esperando?',
      category: 'life',
    ),
    Question(
      id: 'internal_standard_double_bind',
      text:
          '¿Hay estándares que te exiges a ti mismo pero no a otros, o viceversa?',
      category: 'values',
    ),
    Question(
      id: 'self_image_protection',
      text:
          '¿Qué haces para proteger la imagen que tienes de ti mismo cuando algo la contradice?',
      category: 'identity',
    ),
    Question(
      id: 'contradiction_tolerance',
      text:
          '¿Qué contradicción en ti mismo has aprendido a tolerar sin resolver?',
      category: 'meta',
    ),
    Question(
      id: 'invisible_habit_pattern',
      text:
          '¿Qué hábito tienes que influye mucho en tu vida pero casi no notas?',
      category: 'identity',
    ),
    Question(
      id: 'social_mask_activation',
      text:
          '¿En qué contextos sientes que activas una versión de ti más controlada o calculada?',
      category: 'relationships',
    ),
    Question(
      id: 'internal_dialogue_conflict',
      text:
          '¿Cómo suena tu diálogo interno cuando estás dividido entre dos decisiones importantes?',
      category: 'identity',
    ),
    Question(
      id: 'failure_reinterpretation_shift',
      text:
          '¿Recuerdas un fracaso que con el tiempo cambiaste de significado para poder integrarlo?',
      category: 'life',
    ),
    Question(
      id: 'success_hidden_cost',
      text: '¿Hay algún logro que haya tenido un costo que casi nadie ve?',
      category: 'life',
    ),
    Question(
      id: 'empathy_limit_case',
      text: '¿En qué situación te costó más entender o empatizar con alguien?',
      category: 'relationships',
    ),
    Question(
      id: 'self_control_breakpoint',
      text:
          '¿Qué suele hacer que pierdas el control de ti mismo, aunque normalmente lo mantengas?',
      category: 'identity',
    ),
    Question(
      id: 'rationalization_pattern',
      text:
          '¿Qué tipo de justificaciones usas con más frecuencia para explicar decisiones cuestionables?',
      category: 'meta',
    ),
    Question(
      id: 'unacknowledged_envy',
      text: '¿Hay algo que te cuesta admitir que envidias?',
      category: 'values',
    ),
    Question(
      id: 'time_wasting_awareness',
      text:
          '¿En qué sueles gastar tiempo sabiendo que no te acerca a lo que quieres?',
      category: 'life',
    ),
    Question(
      id: 'internal_priority_conflict',
      text: '¿Qué prioridad dices tener pero en la práctica no sostienes?',
      category: 'values',
    ),
    Question(
      id: 'identity_performance_gap',
      text:
          '¿En qué situaciones sientes que interpretas un papel en lugar de actuar con naturalidad?',
      category: 'identity',
    ),
    Question(
      id: 'memory_selective_bias',
      text: '¿Qué tipo de recuerdos tiendes a conservar y cuáles a minimizar?',
      category: 'meta',
    ),
    Question(
      id: 'feedback_resistance_point',
      text:
          '¿Qué tipo de crítica te cuesta más aceptar aunque pueda ser válida?',
      category: 'identity',
    ),
    Question(
      id: 'internal_limit_recognition',
      text:
          '¿Qué límite personal has reconocido pero aún no has logrado cambiar?',
      category: 'identity',
    ),
    Question(
      id: 'decision_identity_attachment',
      text:
          '¿Qué decisiones te cuesta revisar porque ya forman parte de cómo te defines?',
      category: 'identity',
    ),
    Question(
      id: 'hidden_dependency_pattern',
      text: '¿De qué dependes más de lo que te gustaría admitir?',
      category: 'identity',
    ),
    Question(
      id: 'uncertain_belief_core',
      text:
          '¿Qué creencia importante sostienes aunque no estés completamente seguro de que sea cierta?',
      category: 'values',
    ),
  ];

  /// Convenience lookup by id.
  static final Map<String, Question> byId = {for (final q in all) q.id: q};

  /// Returns only questions currently marked as active.
  static List<Question> get active =>
      all.where((q) => q.active).toList(growable: false);
}
