class_name DampedSpring

const epsilon : float = 0.0001



#class SpringDataVec2:
	#@export var damping : float = 0.8
	#@export var frequency : float = 20
	#
	#var velocity : Vector2
	#var current : Vector2
	#var goal : Vector2
	#
	#var OnChange : Callable
	#
	#func update(delta : float) -> void:
		#if OnChange != null: OnChange.call(self)
		

class DampedSpringMotionParams:
	var posPosCoef : float
	var posVelCoef : float
	var velPosCoef : float
	var velVelCoef : float

#******************************************************************************
		# This function will compute the parameters needed to simulate a damped spring
		# over a given period of time.
		# - An angular frequency is given to control how fast the spring oscillates.
		# - A damping ratio is given to control how fast the motion decays.
		#     damping ratio > 1: over damped
		#     damping ratio = 1: critically damped
		#     damping ratio < 1: under damped
		#******************************************************************************
static func CalcDampedSpringMotionParams(deltaTime : float,angularFrequency : float, dampingRatio : float) -> DampedSpringMotionParams:    # damping ratio of motion
	var pOutParams: DampedSpringMotionParams = DampedSpringMotionParams.new()

			# force values into legal range
	if (dampingRatio < 0.0): dampingRatio = 0.0
	if (angularFrequency < 0.0): angularFrequency = 0.0

			# if there is no angular frequency, the spring will not move and we can
			# return identity
	if (angularFrequency < epsilon):
		pOutParams.posPosCoef = 1.0
		pOutParams.posVelCoef = 0.0
		pOutParams.velPosCoef = 0.0
		pOutParams.velVelCoef = 1.0
		return pOutParams;
	if (dampingRatio > 1.0 + epsilon):
		var za : float= -angularFrequency * dampingRatio
		var zb : float= angularFrequency * sqrt(dampingRatio * dampingRatio - 1.0)
		var z1 : float= za - zb
		var z2 : float= za + zb
				# Value e (2.7) raised to a specific power
		var e1 : float= exp(z1 * deltaTime)
		var e2 : float= exp(z2 * deltaTime)
		
		var invTwoZb : float = 1.0 / (2.0 * zb); # = 1 / (z2 - z1)
		
		var e1_Over_TwoZb: float = e1 * invTwoZb
		var e2_Over_TwoZb: float = e2 * invTwoZb
		
		var z1e1_Over_TwoZb : float= z1 * e1_Over_TwoZb
		var z2e2_Over_TwoZb : float= z2 * e2_Over_TwoZb
		
		pOutParams.posPosCoef = e1_Over_TwoZb * z2 - z2e2_Over_TwoZb + e2
		pOutParams.posVelCoef = -e1_Over_TwoZb + e2_Over_TwoZb
		
		pOutParams.velPosCoef = (z1e1_Over_TwoZb - z2e2_Over_TwoZb + e2) * z2
		pOutParams.velVelCoef = -z1e1_Over_TwoZb + z2e2_Over_TwoZb;
		
	elif (dampingRatio < 1.0 - epsilon) :
		var omegaZeta : float= angularFrequency * dampingRatio
		var alpha: float= angularFrequency * sqrt(1.0 - dampingRatio * dampingRatio)
		
		var expTerm: float = exp(-omegaZeta * deltaTime)
		var cosTerm : float= cos(alpha * deltaTime)
		var sinTerm : float= sin(alpha * deltaTime)
		
		var invAlpha : float= 1.0 / alpha
		
		var expSin: float = expTerm * sinTerm
		var expCos : float= expTerm * cosTerm
		var expOmegaZetaSin_Over_Alpha : float= expTerm * omegaZeta * sinTerm * invAlpha
		pOutParams.posPosCoef = expCos + expOmegaZetaSin_Over_Alpha
		pOutParams.posVelCoef = expSin * invAlpha;
		
		pOutParams.velPosCoef = -expSin * alpha - omegaZeta * expOmegaZetaSin_Over_Alpha
		pOutParams.velVelCoef = expCos - expOmegaZetaSin_Over_Alpha
	else:
		
				# critically damped
		var expTerm : float= exp(-angularFrequency * deltaTime)
		var timeExp : float= deltaTime * expTerm
		var timeExpFreq : float= timeExp * angularFrequency
		
		pOutParams.posPosCoef = timeExpFreq + expTerm
		pOutParams.posVelCoef = timeExp
		
		pOutParams.velPosCoef = -angularFrequency * timeExpFreq
		pOutParams.velVelCoef = -timeExpFreq + expTerm
		
	return pOutParams;

		#******************************************************************************
		# This function will update the supplied position and velocity values over
		# according to the motion parameters.
		#******************************************************************************
static func UpdateDampedSpringMotion(pPos : float,pVel : float,equilibriumPos : float, parameters : DampedSpringMotionParams)  -> Vector2 :
	var oldPos :float = pPos - equilibriumPos; # update in equilibrium relative space
	var oldVel :float= pVel
	
	pPos = oldPos * parameters.posPosCoef + oldVel * parameters.posVelCoef + equilibriumPos
	pVel = oldPos * parameters.velPosCoef + oldVel * parameters.velVelCoef;
	return Vector2(pPos, pVel)

		#/ <summary>
		#/ Calculate a spring motion development for a given deltaTime
		#/ </summary>
		#/ <param name="position">"Live" position value</param>
		#/ <param name="velocity">"Live" velocity value</param>
		#/ <param name="equilibriumPosition">Goal (or rest) position</param>
		#/ <param name="deltaTime">Time to update over</param>
		#/ <param name="angularFrequency">Angular frequency of motion</param>
		#/ <param name="dampingRatio">Damping ratio of motion</param>
static func CalcDampedSimpleHarmonicMotion(position:float, velocity:float, equilibriumPosition:float, deltaTime:float, angularFrequency:float, dampingRatio:float) -> Vector2:
	var motionParams:DampedSpringMotionParams= CalcDampedSpringMotionParams(deltaTime, angularFrequency, dampingRatio)
	var retVals:Vector2 = UpdateDampedSpringMotion(position, velocity, equilibriumPosition, motionParams)
	return retVals

		#/ <summary>
		#/ Calculate a spring motion development for a given deltaTime
		#/ </summary>
		#/ <param name="position">"Live" position value</param>
		#/ <param name="velocity">"Live" velocity value</param>
		#/ <param name="equilibriumPosition">Goal (or rest) position</param>
		#/ <param name="deltaTime">Time to update over</param>
		#/ <param name="angularFrequency">Angular frequency of motion</param>
		#/ <param name="dampingRatio">Damping ratio of motion</param>
static func CalcDampedSimpleHarmonicMotionVec2(position:Vector2,velocity:Vector2,equilibriumPosition:Vector2, deltaTime:float, angularFrequency:float, dampingRatio:float) -> Vector4:
	var motionParams:DampedSpringMotionParams= CalcDampedSpringMotionParams(deltaTime, angularFrequency, dampingRatio)
	var x:Vector2 = UpdateDampedSpringMotion(position.x, velocity.x, equilibriumPosition.x, motionParams)
	var y:Vector2 = UpdateDampedSpringMotion(position.y, velocity.y, equilibriumPosition.y, motionParams)
	return Vector4(x.x, y.x, x.y, y.y)

