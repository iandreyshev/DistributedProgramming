﻿using Backend.Repository;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers
{
	[Route("api/[controller]")]
	public class TextDetailsController : Controller
	{
		private const int REPEATS_COUNT = 5;
		private const int REPEAT_PAUSE_MS = 100;
		private const string RESULT_ID_PREFIX = "TextRank_";

		private IRepository _repository;

		public TextDetailsController(IRepository repository)
		{
			_repository = repository;
		}

		// GET api/TextDetails/{id}
		[HttpGet("{id}")]
		public IActionResult Get(string id)
		{
			string result = null;

			Utils.LambdaUtils.Repeat(REPEATS_COUNT, REPEAT_PAUSE_MS, (_) => {
				result = _repository.GetString(RESULT_ID_PREFIX + id);
				return result != null;
			});

			if (result == null)
			{
				return NotFound();
			}

			return Ok(result);
		}

		// GET api/TextDetails/Statistic
		[HttpGet("Statistic")]
		public IActionResult Get()
		{
			var result = string.Format(
				"Count: {0}, Best count: {1}, Average value: {2}",
				_repository.GetString("RESULT_COUNT", "Undefined"),
				_repository.GetString("RESULT_BEST_COUNT", "Undefined"),
				_repository.GetString("RESULT_AVG", "Undefined"));

			return Ok(result);
		}
	}
}
